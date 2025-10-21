// Test normalization logic for WhatsApp payloads
function normalizePayload(itemsJson) {
  var payload = itemsJson || {};
  try {
    if (payload && typeof payload.body === 'string') {
      try { payload = JSON.parse(payload.body); } catch (e) { /* ignore parse errors */ }
    } else if (payload && typeof payload.body === 'object' && payload.body !== null) {
      payload = payload.body;
    }
  } catch (e) { /* ignore */ }
  var text = '';
  var from = '';
  try {
    var entries = payload.entry;
    if (Array.isArray(entries) && entries.length > 0) {
      var changes = entries[0].changes;
      if (Array.isArray(changes) && changes.length > 0) {
        var value = changes[0].value;
        var messages = value && value.messages;
        if (Array.isArray(messages) && messages.length > 0) {
          var msg = messages[0];
          if (msg && msg.text && msg.text.body) text = msg.text.body;
          if (msg && msg.from) from = msg.from;
        }
      }
    }
  } catch (e) { /* ignore */ }
  return { user_text: text, from: from };
}

const sampleEntry = {
  entry: [
    {
      changes: [
        {
          value: {
            messages: [
              {
                from: '12345',
                text: { body: 'Halo dari test script' }
              }
            ]
          }
        }
      ]
    }
  ]
};

const direct = sampleEntry;
const wrappedObject = { body: sampleEntry };
const wrappedString = { body: JSON.stringify(sampleEntry) };

console.log('Direct payload:', normalizePayload(direct));
console.log('Wrapped object in body:', normalizePayload(wrappedObject));
console.log('Wrapped JSON string in body:', normalizePayload(wrappedString));
