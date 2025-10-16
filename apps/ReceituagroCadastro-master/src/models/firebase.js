import firebase from 'firebase/app'
import 'firebase/auth'
import 'firebase/storage'
import 'firebase/database'

export const firebaseApp = firebase.initializeApp({
  apiKey: "AIzaSyBkzLM-mlYE-m9ODLyIhFyow1McFiWGFCI",
  authDomain: "receituagro.firebaseapp.com",
  databaseURL: "https://receituagro-default-rtdb.firebaseio.com",
  projectId: "receituagro",
  storageBucket: "receituagro.appspot.com",
  messagingSenderId: "446258505830",
  appId: "1:446258505830:web:2668e79717f72dcf8ce5a7"
})

export default function install (Vue) {
  Object.defineProperty(Vue.prototype, '$firebase', {
    get () {
      return firebaseApp
    }
  })
}