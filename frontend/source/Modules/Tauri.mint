module Tauri.Fs {
  /* Reads a the file on the given path. */
  fun readTextFile (path : String) : Promise(Never, String) {
    `Tauri.fs.readTextFile(#{path})`
  }

  /* Writes the given contents to the file on the given path. */
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
  /* Resovles the given path based on the base directory. */
  fun resolvePath (path : String) : Promise(Never, String) {
    `Tauri.path.resolvePath(#{path}, Tauri.fs.BaseDirectory.Config)`
  }
}
