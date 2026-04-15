// Copyright 2026 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
priv struct StateId(Int64)

///|
let pending_state_id : StateId = -1

///|
const MAX_STATE_INDEX : Int = 0b1111_1111_1111_1111_1110

///|
const MAX_SLOT_INDEX : Int = 0b111_1111_1111

///|
const MAX_NUM_SYMBOLS : Int = 0b111_1111_1110

///|
const MAX_TRANSITION_BASE : Int64 = 0x7fff_ffffL

///|
fn StateId::new(
  index~ : Int,
  slot~ : @automata.Slot,
  is_break~ : Bool,
  num_symbols~ : Int,
) -> StateId {
  guard index >= 0 && index <= MAX_STATE_INDEX else { panic() }
  guard slot.index >= 0 && slot.index <= MAX_SLOT_INDEX else { panic() }
  guard num_symbols > 0 && num_symbols <= MAX_NUM_SYMBOLS else { panic() }
  let transition_base64 = index.to_int64() * num_symbols.to_int64()
  guard transition_base64 >= 0L && transition_base64 <= MAX_TRANSITION_BASE else {
    panic()
  }
  let transition_base = transition_base64.to_int()
  debug_assert(() => {
    index <= MAX_STATE_INDEX &&
    slot.index <= MAX_SLOT_INDEX &&
    num_symbols <= MAX_NUM_SYMBOLS
  })
  let encoded_index = if is_break { -2 - index } else { index }
  let id = StateId(
    (((encoded_index << 11) | slot.index).to_int64() << 32) |
    transition_base.to_int64(),
  )
  debug_assert(() => {
    id.index() == index && id.slot() == slot && id.is_break() == is_break
  })
  id
}

///|
fn StateId::is_pending(self : StateId) -> Bool {
  self.0 == -1
}

///|
fn StateId::is_break(self : StateId) -> Bool {
  self.0 < -1
}

///|
fn StateId::transition_base(self : StateId) -> Int {
  self.0.to_int()
}

///|
fn StateId::index(self : StateId) -> Int {
  let x = (self.0 >> 43).to_int()
  if x < 0 {
    -(x + 2)
  } else {
    x
  }
}

///|
fn StateId::slot(self : StateId) -> @automata.Slot {
  @automata.Slot::from_index((self.0 >> 32).to_int() & 0b111_1111_1111)
}
