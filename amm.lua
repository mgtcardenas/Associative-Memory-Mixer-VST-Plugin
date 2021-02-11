require('mix')

function pathAChanged()
  print("pathA changed to", pathA)
end

defineParameter("pathA", nil, "untitledA", pathAChanged)

function pathBChanged()
  print("pathB changed to", pathB)
end

defineParameter("pathB", nil, "untitledB", pathBChanged)

constante_ruta_A = "C:/temp/a.mid"
constante_ruta_B = "C:/temp/b.mid"

function onNote(event)
  runAsync(run, pathA, pathB)
end

function printMidiInformation(midiseq)
  -- information from the header chunk
  print("Standard MIDI File Format:", midiseq.format)
  print("SMPTE:", midiseq.smpteformat)
  print("Division:", midiseq.division)

  -- information from the track chunk
  print("Tempo:", midiseq.tempo)
  print("Signature:", midiseq.signature.numerator, "/", midiseq.signature.denominator)
  print("Song Name:", midiseq.songname)
  print("Number of Tracks:", #midiseq.tracks)
  print("Name of 1st Track:", midiseq.tracks[1].name)
  print("Channel of 1st Track:", midiseq.tracks[1].channel)
  print("Number of Events in 1st Track", #midiseq.tracks[1].events, "\n")
end

function run(rutaA, rutaB)
  midiSequenceA = readMidiFile(rutaA)
  print("MIDI A")
  printMidiInformation(midiSequenceA)

  midiSequenceB = readMidiFile(rutaB)
  print("MIDI B")
  printMidiInformation(midiSequenceB)

  mix(midiSequenceA, midiSequenceB)
end