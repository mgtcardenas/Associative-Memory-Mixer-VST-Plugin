require('mix')

function pathAChanged()
  print("pathA changed to", pathA)
end

defineParameter("pathA", nil, "untitledA", pathAChanged)

function pathBChanged()
  print("pathB changed to", pathB)
end

defineParameter("pathB", nil, "untitledB", pathBChanged)

function onNote(event)
  runAsync(run, pathA, pathB)
end

function run(rutaA, rutaB)
  midiSequenceA = readMidiFile(rutaA)
  midiSequenceB = readMidiFile(rutaB)
  mix(midiSequenceA, midiSequenceB)
end