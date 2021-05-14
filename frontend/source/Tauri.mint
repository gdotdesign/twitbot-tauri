module Tauri.Fs {
  fun readTextFile (path : String) : Promise(Never, String) {
    `Tauri.fs.readTextFile(#{path})`
  }

  fun writeFile (path : String, contents : String) : Promise(Never, Void) {
    `
    Tauri.fs.writeFile({
      path: #{path},
      contents: #{contents}
    })
    `
  }
}

module Tauri.Path {
  fun resolvePath (path : String) : Promise(Never, String) {
    `Tauri.path.resolvePath(#{path}, Tauri.fs.BaseDirectory.Config)`
  }
}

module Tauri.Notification {
  fun sendNotification (title : String, body : String, icon : String) {
    `Tauri.notification.sendNotification({ title: #{title}, body: #{body}, icon: #{icon} })`
  }
}
