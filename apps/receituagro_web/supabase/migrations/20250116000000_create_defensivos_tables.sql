-- ============================================================================
-- Migration: Create Defensivos Tables
-- Description: Creates tables for defensivos cadastro system
-- - defensivos: Main table with 17 fields
-- - diagnosticos: Many-to-many relationship (Defensivo x Cultura x Praga)
-- - defensivos_info: 1:1 complementary information (7 long-text fields)
-- ============================================================================

-- ============================================================================
-- Table: defensivos
-- Description: Main table for agricultural defensives (fitossanitários)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.defensivos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Identification (required)
    nome_comum TEXT NOT NULL,
    nome_tecnico TEXT,
    fabricante TEXT NOT NULL,
    ingrediente_ativo TEXT NOT NULL,

    -- Characteristics
    quant_produto TEXT, -- Product quantity
    mapa TEXT, -- MAPA registration number
    formulacao TEXT, -- EC, SC, WG, etc
    modo_acao TEXT, -- Systemic, contact, etc
    classe_agronomica TEXT,

    -- Classification & Safety
    toxico TEXT, -- Toxicological class (I, II, III, IV)
    class_ambiental TEXT, -- Environmental class (I, II, III, IV)
    inflamavel TEXT, -- Flammable (Yes/No)
    corrosivo TEXT, -- Corrosive (Yes/No)
    comercializado TEXT, -- Commercially available (Yes/No)

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Indexes for defensivos
CREATE INDEX IF NOT EXISTS idx_defensivos_nome_comum ON public.defensivos(nome_comum);
CREATE INDEX IF NOT EXISTS idx_defensivos_fabricante ON public.defensivos(fabricante);
CREATE INDEX IF NOT EXISTS idx_defensivos_ingrediente_ativo ON public.defensivos(ingrediente_ativo);

-- ============================================================================
-- Table: diagnosticos
-- Description: Many-to-many relationship between defensivos, culturas, and pragas
-- Contains dosage and application information
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.diagnosticos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Keys (many-to-many relationship)
    defensivo_id UUID NOT NULL REFERENCES public.defensivos(id) ON DELETE CASCADE,
    cultura_id UUID NOT NULL, -- References culturas table
    praga_id UUID NOT NULL, -- References pragas table

    -- Dosage (dose per hectare)
    ds_min TEXT, -- Minimum dose
    ds_max TEXT, -- Maximum dose
    um TEXT, -- Unit of measure (L/ha, kg/ha)

    -- Terrestrial Application (volume per hectare)
    min_aplicacao_t TEXT, -- Minimum volume terrestrial
    max_aplicacao_t TEXT, -- Maximum volume terrestrial
    um_t TEXT, -- Unit terrestrial (L/ha)

    -- Aerial Application (volume per hectare)
    min_aplicacao_a TEXT, -- Minimum volume aerial
    max_aplicacao_a TEXT, -- Maximum volume aerial
    um_a TEXT, -- Unit aerial (L/ha)

    -- Intervals & Application Period
    intervalo TEXT, -- Safety interval (days)
    intervalo2 TEXT, -- Re-entry interval
    epoca_aplicacao TEXT, -- Application period/season

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Indexes for diagnosticos
CREATE INDEX IF NOT EXISTS idx_diagnosticos_defensivo_id ON public.diagnosticos(defensivo_id);
CREATE INDEX IF NOT EXISTS idx_diagnosticos_cultura_id ON public.diagnosticos(cultura_id);
CREATE INDEX IF NOT EXISTS idx_diagnosticos_praga_id ON public.diagnosticos(praga_id);

-- Composite index for unique combinations
CREATE UNIQUE INDEX IF NOT EXISTS idx_diagnosticos_unique_combination
    ON public.diagnosticos(defensivo_id, cultura_id, praga_id);

-- ============================================================================
-- Table: defensivos_info
-- Description: Complementary long-text information for defensivos (1:1 relationship)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.defensivos_info (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Foreign Key (1:1 relationship)
    defensivo_id UUID NOT NULL UNIQUE REFERENCES public.defensivos(id) ON DELETE CASCADE,

    -- Long-text complementary fields
    embalagens TEXT, -- Packaging and storage information
    tecnologia TEXT, -- Application technology (equipment, nozzles, pressure)
    p_humanas TEXT, -- Human health precautions (PPE, first aid)
    p_ambiental TEXT, -- Environmental precautions (water bodies, fauna)
    manejo_resistencia TEXT, -- Resistance management (rotation, alternation)
    compatibilidade TEXT, -- Compatibility with other products
    manejo_integrado TEXT, -- Integrated pest management (IPM)

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Index for defensivos_info
CREATE INDEX IF NOT EXISTS idx_defensivos_info_defensivo_id ON public.defensivos_info(defensivo_id);

-- ============================================================================
-- Triggers: Update updated_at timestamp automatically
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to defensivos
DROP TRIGGER IF EXISTS update_defensivos_updated_at ON public.defensivos;
CREATE TRIGGER update_defensivos_updated_at
    BEFORE UPDATE ON public.defensivos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to diagnosticos
DROP TRIGGER IF EXISTS update_diagnosticos_updated_at ON public.diagnosticos;
CREATE TRIGGER update_diagnosticos_updated_at
    BEFORE UPDATE ON public.diagnosticos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to defensivos_info
DROP TRIGGER IF EXISTS update_defensivos_info_updated_at ON public.defensivos_info;
CREATE TRIGGER update_defensivos_info_updated_at
    BEFORE UPDATE ON public.defensivos_info
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Row Level Security (RLS) Policies
-- Enable RLS and create policies for authenticated users
-- ============================================================================

-- Enable RLS
ALTER TABLE public.defensivos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.diagnosticos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.defensivos_info ENABLE ROW LEVEL SECURITY;

-- Policies for defensivos (Admin and Editor can manage, all authenticated can read)
CREATE POLICY "Allow authenticated users to read defensivos"
    ON public.defensivos FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow admin and editor to insert defensivos"
    ON public.defensivos FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid()
            AND users.role IN ('admin', 'editor')
        )
    );

CREATE POLICY "Allow admin and editor to update defensivos"
    ON public.defensivos FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid()
            AND users.role IN ('admin', 'editor')
        )
    );

CREATE POLICY "Allow admin to delete defensivos"
    ON public.defensivos FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid()
            AND users.role = 'admin'
        )
    );

-- Policies for diagnosticos (same as defensivos)
CREATE POLICY "Allow authenticated users to read diagnosticos"
    ON public.diagnosticos FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow admin and editor to manage diagnosticos"
    ON public.diagnosticos FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid()
            AND users.role IN ('admin', 'editor')
        )
    );

-- Policies for defensivos_info (same as defensivos)
CREATE POLICY "Allow authenticated users to read defensivos_info"
    ON public.defensivos_info FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow admin and editor to manage defensivos_info"
    ON public.defensivos_info FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid()
            AND users.role IN ('admin', 'editor')
        )
    );

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON TABLE public.defensivos IS 'Agricultural defensives (fitossanitários) main table';
COMMENT ON TABLE public.diagnosticos IS 'Many-to-many relationship: defensivo x cultura x praga with dosage info';
COMMENT ON TABLE public.defensivos_info IS 'Complementary long-text information for defensivos (1:1)';

COMMENT ON COLUMN public.defensivos.mapa IS 'Ministry of Agriculture registration number';
COMMENT ON COLUMN public.defensivos.formulacao IS 'Product formulation: EC, SC, WG, etc';
COMMENT ON COLUMN public.diagnosticos.ds_min IS 'Minimum dose per hectare';
COMMENT ON COLUMN public.diagnosticos.um IS 'Unit of measure: L/ha, kg/ha, etc';
COMMENT ON COLUMN public.diagnosticos.min_aplicacao_t IS 'Minimum volume terrestrial application (L/ha)';
COMMENT ON COLUMN public.diagnosticos.min_aplicacao_a IS 'Minimum volume aerial application (L/ha)';
COMMENT ON COLUMN public.diagnosticos.intervalo IS 'Safety interval in days';
