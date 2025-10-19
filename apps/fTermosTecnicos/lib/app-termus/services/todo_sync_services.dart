// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hive/hive.dart';

// class SyncService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> syncTodos() async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     final todoBox = Hive.box<Todo>('todos');
//     final todos = todoBox.values.toList();

//     // Carregar dados do Firestore
//     final firestoreTodosSnapshot = await _firestore
//         .collection('todos')
//         .where('userId', isEqualTo: user.uid)
//         .get();
//     final firestoreTodos = firestoreTodosSnapshot.docs.map((doc) => Todo(
//       id: doc.id,
//       task: doc['task'],
//       completed: doc['completed'],
//       createdAt: (doc['createdAt'] as Timestamp).toDate(),
//       updatedAt: (doc['updatedAt'] as Timestamp).toDate(),
//       status: doc['status'],
//     )).toList();

//     // Sincronizar dados
//     for (var todo in todos) {
//       final matchingTodo = firestoreTodos.firstWhere((ft) => ft.id == todo.id, orElse: () => null);
//       if (matchingTodo == null) {
//         // Adicionar ao Firestore
//         await _firestore.collection('todos').add({
//           'userId': user.uid,
//           'task': todo.task,
//           'completed': todo.completed,
//           'createdAt': todo.createdAt,
//           'updatedAt': todo.updatedAt,
//           'status': todo.status,
//         });
//       } else if (matchingTodo.updatedAt.isBefore(todo.updatedAt)) {
//         // Atualizar no Firestore
//         await _firestore.collection('todos').doc(matchingTodo.id).update({
//           'task': todo.task,
//           'completed': todo.completed,
//           'updatedAt': todo.updatedAt,
//           'status': todo.status,
//         });
//       }
//     }

//     for (var firestoreTodo in firestoreTodos) {
//       final matchingTodo = todos.firstWhere((t) => t.id == firestoreTodo.id, orElse: () => null);
//       if (matchingTodo == null) {
//         // Adicionar ao Hive
//         todoBox.put(firestoreTodo.id, firestoreTodo);
//       } else if (matchingTodo.updatedAt.isBefore(firestoreTodo.updatedAt)) {
//         // Atualizar no Hive
//         todoBox.put(matchingTodo.id, firestoreTodo);
//       }
//     }
//   }
// }
