import json

def normalize(payload):
    p = payload or {}
    try:
        if isinstance(p.get('body'), str):
            try:
                p = json.loads(p['body'])
            except Exception:
                pass
        elif isinstance(p.get('body'), dict):
            p = p['body']
    except Exception:
        pass
    text = ''
    frm = ''
    try:
        entries = p.get('entry')
        if isinstance(entries, list) and len(entries) > 0:
            changes = entries[0].get('changes')
            if isinstance(changes, list) and len(changes) > 0:
                value = changes[0].get('value')
                messages = value and value.get('messages')
                if isinstance(messages, list) and len(messages) > 0:
                    msg = messages[0]
                    if msg and msg.get('text') and msg['text'].get('body'):
                        text = msg['text']['body']
                    if msg and msg.get('from'):
                        frm = msg['from']
    except Exception:
        pass
    return {'user_text': text, 'from': frm}

sample = {
  'entry': [
    {'changes': [
      {'value': {'messages': [{'from': '12345', 'text': {'body': 'Halo dari test script'}}]}}
    ]}
  ]
}

direct = sample
wrapped_obj = {'body': sample}
wrapped_str = {'body': json.dumps(sample)}

print('direct:', normalize(direct))
print('wrapped_obj:', normalize(wrapped_obj))
print('wrapped_str:', normalize(wrapped_str))
