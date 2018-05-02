%x(git rev-parse HEAD > REVISION)
CurrentCommit = (File.read('REVISION').strip if File.readable?('REVISION'))
