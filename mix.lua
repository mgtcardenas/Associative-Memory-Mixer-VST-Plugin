require('utils')

function fill_z_vector(events, z_vector, ppq_position_limit)
  for i = 1, #events, 1 do
    if events[i].ppqPosition < ppq_position_limit then
      if events[i].type == EventType.noteOn then
        for j = i + 1, #events, 1 do
          if events[j].type == EventType.noteOff and events[i].note == events[j].note and events[j].ppqPosition <= ppq_position_limit then
            -- 4.1.b. Fill with 1s the row from j1 to j2 (where j2 >= j1 and j1 & j2 are column indices) using the following parameters.
            i1 = absolute_highest_note - events[i].note + 1 -- the row in the piano roll representation matrix
            j1 = math.floor(events[i].ppqPosition * magnification_factor + 0.5) + 1 -- the start column in the piano roll representation matrix; + 0.5 is to make math.floor equivalent to math.round
            j2 = math.floor(events[j].ppqPosition * magnification_factor + 0.5) + 1 -- the end column in the piano roll representation matrix; + 0.5 is to make math.floor equivalent to math.round
            xi = (i1 - 1) * n + (j1 - 1) + 1
            xj = (i1 - 1) * n + (j2 - 1) + 1
            -- print(i1, j1, j2, events[i], events[j], xi, xj)
            for z = xi, xj, 1 do
              z_vector[z] = 1
            end -- for - z
            break -- just find the first closest noteOff event within the ppq_position_limit
          elseif events[j].type == EventType.noteOff and events[i].note == events[j].note and events[j].ppqPosition > ppq_position_limit then
            break -- The noteOff event of the current note (i) is beyond the ppq_position_limit
          end -- if noteOff
        end -- for - j
      end -- if noteOn
    else
      break -- we are looking at the notes which begin after the ppq_position_limit, we are done!
    end -- if before ppq_position_limit
  end -- for - i
end -- fill_z_vector

function mix(midi_sequence_a, midi_sequence_b, result_path, silence_rate, lower_diff_percentage, upper_diff_percentage, num_attempts, ppq_position_limit)
  -- 0. ESTABLISH CONSTANTS
  magnification_factor = 1
  p = 2 -- p is the number of patterns

  --[[ 1. PREPROCESS MIDI FILE A -- ]]
  -- 1.1 Find the track that has events in MIDI A
  midi_a_track_num = 1
  for i = 1, #midi_sequence_a.tracks, 1 do
    if (#midi_sequence_a.tracks[i].events > 0) then
      midi_a_track_num = i
      break
    end
  end

  if (#midi_sequence_a.tracks[midi_a_track_num].events == 0) then
    messageBox("MIDI A has no tracks with events in it")
    return
  end

  --print("MIDI A Track Num: " .. midi_a_track_num)

  -- 1.2 Sort its events (to ensure that the following steps will work correctly)
  sortEvents(midi_sequence_a.tracks[midi_a_track_num].events)

  --[[ 1.3 Loop through the NoteOffEvents and keep track of ???
    a. The lowest note
    b. The highest note (difference between this and the lowest note is the number of rows)
    c. The greatest PPQPosition value. This value multiplied by the 'magnification_factor'(arbitrary value) is the number of columns
  --]]
  midi_a_lowest_note = math.huge
  midi_a_highest_note = -math.huge
  midi_a_largest_ppqposition = -math.huge -- math.huge = infinite. It is possible to do -math.huge to get minus infinite

  for i, event in ipairs(midi_sequence_a.tracks[midi_a_track_num].events) do
    if event.type == EventType.noteOff and event.ppqPosition <= ppq_position_limit then
      if event.note < midi_a_lowest_note then
        midi_a_lowest_note = event.note
      end
      if event.note > midi_a_highest_note then
        midi_a_highest_note = event.note
      end
      if event.ppqPosition > midi_a_largest_ppqposition then
        midi_a_largest_ppqposition = event.ppqPosition
      end
      -- print(i, event)
    elseif event.type == EventType.noteOff and event.ppqPosition > ppq_position_limit then
      break
    end -- if
  end -- for

  --print("The lowest note in midi a is: " .. midi_a_lowest_note)
  --print("The highest note in midi a is: " .. midi_a_highest_note)
  --print("The largest ppqposition in midi a is: " .. midi_a_largest_ppqposition)

  --[[ 2. PREPROCESS MIDI FILE B -- ]]
  -- 2.1 Find the track that has events in MIDI B
  midi_b_track_num = 1
  for i = 1, #midi_sequence_b.tracks, 1 do
    if (#midi_sequence_b.tracks[i].events > 0) then
      midi_b_track_num = i
      break
    end
  end

  if (#midi_sequence_b.tracks[midi_b_track_num].events == 0) then
    messageBox("MIDI B has no tracks with events in it")
    return
  end

  --print("MIDI B Track Num: " .. midi_b_track_num)

  -- 2.2 Sort its events (to ensure that the following steps will work correctly)
  sortEvents(midi_sequence_b.tracks[midi_b_track_num].events)

  --[[ 2.3 Loop through the NoteOffEvents and keep track of ???
    a. The lowest note
    b. The highest note (difference between this and the lowest note is the number of rows)
    c. The greatest PPQPosition value. This value divided by 0.25 (arbitrary division) is the number of columns
  --]]
  midi_b_lowest_note = math.huge
  midi_b_highest_note = -math.huge
  midi_b_largest_ppqposition = -math.huge -- math.huge = infinite. It is possible to do -math.huge to get minus infinite

  for i, event in ipairs(midi_sequence_b.tracks[midi_b_track_num].events) do
    if event.type == EventType.noteOff and event.ppqPosition <= ppq_position_limit then
      if event.note < midi_b_lowest_note then
        midi_b_lowest_note = event.note
      end
      if event.note > midi_b_highest_note then
        midi_b_highest_note = event.note
      end
      if event.ppqPosition > midi_b_largest_ppqposition then
        midi_b_largest_ppqposition = event.ppqPosition
      end
      -- print(i, event)
    elseif event.type == EventType.noteOff and event.ppqPosition > ppq_position_limit then
      break
    end -- if
  end -- for

  --print("The lowest note in midi b is: " .. midi_b_lowest_note)
  --print("The highest note in midi b is: " .. midi_b_highest_note)
  --print("The largest ppqposition in midi b is: " .. midi_b_largest_ppqposition)

  --[[ 3. PREPARE for Z VECTORS -- ]]
  -- 3.1 Obtain the following variables
  absolute_lowest_note = math.min(midi_a_lowest_note, midi_b_lowest_note)
  absolute_highest_note = math.max(midi_a_highest_note, midi_b_highest_note)
  absolute_largest_ppqposition = math.max(midi_a_largest_ppqposition, midi_a_largest_ppqposition)

  --print("The absolute lowest note is: " .. absolute_lowest_note)
  --print("The absolute highest note is: " .. absolute_highest_note)
  --print("The absolute largest ppqposition is: " .. absolute_largest_ppqposition)


  --3.2 Create a table (array) full of zeroes (or -1s) with size (m x n) for each of the MIDI files???
  m = absolute_highest_note - absolute_lowest_note + 1 -- + 1 because 1-based Lua tables
  n = absolute_largest_ppqposition * magnification_factor + 1 -- + 1 in order to avoid incorrectly filling the z vectors (training vectors)
  --print("m = " .. m)
  --print("n = " .. n)

  -- 3.3 Establish the limits for the acceptable number of notes
  lower_diff_limit = math.floor((m * n) * lower_diff_percentage)
  upper_diff_limit = math.floor((m * n) * upper_diff_percentage)
  --  print("lower_diff_limit = " .. lower_diff_limit)
  --  print("upper_diff_limit = " .. upper_diff_limit)

  --[[ 4. FILL ZA (VECTOR OF NOTES A) -- ]]
  za = get_table_full_of_minus_ones(m * n)
  -- print("Size of table full of minus ones = " .. #za)
  -- print("The last value in za is " .. za[#za])

  -- 4.1 Iterate through all the NoteOnEvents.
  -- 4.1.a. For every NoteOnEvent, search starting from the index of the just found NoteOnEvent looking for the closest NoteOffEvent that corresponds to the same MIDI Note Value.
  eventsA = midi_sequence_a.tracks[midi_a_track_num].events
  fill_z_vector(eventsA, za, ppq_position_limit)

  --[[ 5. FILL ZB (VECTOR OF NOTES B) -- ]]
  zb = get_table_full_of_minus_ones(m * n)
  -- 5.1 Iterate through all the NoteOnEvents.
  -- 5.1.a. For every NoteOnEvent, search starting from the index of the just found NoteOnEvent looking for the closest NoteOffEvent that corresponds to the same MIDI Note Value.
  eventsB = midi_sequence_b.tracks[midi_b_track_num].events
  fill_z_vector(eventsB, zb, ppq_position_limit)

  --[[ 6. OBTAIN ii --]]
  ii = matrix_scalar_dot_product(get_identity_matrix(m * n), p / (m * n))

  --[[ 7. PREPARE MATRIX W --]]
  w1 = outerproduct(za, za)
  w2 = outerproduct(zb, zb)
  w = add_matrices(w1, w2)
  w = matrix_scalar_dot_product(w, 1 / (m * n))
  w = subtract_matrices(w, ii)

  --[[ 8. OBTAIN VARIATION GIVEN RANDOM INPUT --]]
  while (num_attempts > 0) do
    -- print("Trying...")
    -- 8.1. generate a table of size m * n with random zeroes (-1s) and ones (1s)
    x = get_random_input(m * n, silence_rate)
    -- 8.2. slightly transform the random input using matrix w
    u = vector_matrix_dot_product(x, w)
    -- 8.3. apply the activation function to get the result
    result = vectorized_bipolar_step(u)
    -- 8.4. calculate the binary differences between the result and the samples for later appraisal
    diff1 = calculate_binary_difference(za, result)
    -- print("diff1 is: " .. diff1)
    diff2 = calculate_binary_difference(zb, result)
    -- print("diff2 is: " .. diff2)
    -- 8.5. if the resulting vector is sufficiently different, then ok. Else start again from new input
    if lower_diff_limit < diff1 and diff1 < upper_diff_limit and lower_diff_limit < diff2 and diff2 < upper_diff_limit then
      print("It happened")
      break
    end -- if
    num_attempts = num_attempts - 1
  end -- while

  --[[ 9. TRANSFORM VARIATION RESULT INTO MIDI FILE --]]
  -- 9.1 Create a new MIDI sequence table
  midiSequence = { tracks = { { events = {} } } }

  -- 9.2 Loop through the result vector from the previous step.
  x = 1
  while (x <= #result) do
    -- When encountering a 1...
    if (result[x] == 1) then
      -- Transform vector index to matrix indices (using 1-based array arithmetic)
      -- This gives the matrix indices i and j from vector index x.
      i = math.ceil(x / n)
      j = (x - 1) % n + 1

      -- Add a NoteOn event witch pitch equal to absolute_highest_note - (i - 1) on PPQPosition j
      local noteOn = Event(EventType.noteOn)
      noteOn.note = absolute_highest_note - (i - 1)
      noteOn.velocity = 100
      noteOn.ppqPosition = j / magnification_factor

      -- Loop and skip until a -1 is found or it is the last column of matrix
      while (result[x] == 1 and x % n ~= 0) do
        x = x + 1
      end

      -- Add a NoteOff event with pitch equal to absolute_highest_note - (i - 1) on the following PPQPosition
      local noteOff = Event(EventType.noteOff)
      noteOff.note = absolute_highest_note - (i - 1)
      noteOff.velocity = 100
      -- If there is a note in the last position/column, put the NoteOff event one PPQPosition after it (n + 1)
      -- Else just use the column position
      noteOff.ppqPosition = (x % n == 0 and n + 1 or x % n) / magnification_factor

      -- print("i=" .. i .. " j=" .. j .. " thus note is " .. noteOn.note .. " note off is in =" .. (x % n == 0 and n + 1 or x % n))

      -- insert the events
      insertEvent(midiSequence.tracks[1].events, noteOn)
      insertEvent(midiSequence.tracks[1].events, noteOff)
    end -- if

    x = x + 1
  end -- while

  -- 9.3 Sort the events to avoid incoherently writing the MIDI file
  sortEvents(midiSequence.tracks[1].events)
  -- 9.4 Write the result in a MIDI file
  saveState = writeMidiFile(result_path, midiSequence)
end
