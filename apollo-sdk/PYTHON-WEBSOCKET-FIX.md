# Python WebSocket Authentication Fix

## Overview

Similar to the TypeScript SDK, the Python SDK requires a custom fix to send the API key as a **query parameter** instead of a header for WebSocket connections.

## The Problem

Fern's Python SDK generator creates WebSocket clients that send authentication via headers:
```python
headers = self._raw_client._client_wrapper.get_headers()  # Includes x-network-api-key
websockets_sync_client.connect(ws_url, additional_headers=headers)  # ❌ Wrong
```

But the WebSocket API requires the API key as a **query parameter**:
```
wss://api-staging.internal-aui.io/ia-controller/api/v1/external/session?network_api_key=YOUR_KEY
```

## The Fix

Update `/src/aui/external_session/client.py` (in PyPI published package or GitHub if used):

### Key Changes:

1. **Extract API key from client wrapper**:
```python
api_key = (
    self._raw_client._client_wrapper._network_api_key 
    or self._raw_client._client_wrapper.api_key
)
```

2. **Add as query parameter**:
```python
from urllib.parse import urlencode

query_params = {"network_api_key": api_key}
ws_url = f"{ws_url_base}?{urlencode(query_params)}"
```

3. **Remove auth from headers**:
```python
headers = {}  # Empty, auth is in query params
if request_options and "additional_headers" in request_options:
    headers.update(request_options["additional_headers"])
```

## Complete Fixed Code

See the reference implementation in the generated local SDK:
- Location: `generated-sdks/python/external_session/client.py`
- Apply the same fix pattern as TypeScript's `Client.ts`

## For PyPI Publishing

If/when PyPI publishing is enabled (with `PYPI_TOKEN`):

1. **Option A**: Fern might support GitHub for Python too
   - Add Python files to `aui-io/apollo-sdk` GitHub repo
   - Update `.fernignore` to protect `src/aui/external_session/client.py`
   - GitHub Actions workflow would build and publish to PyPI

2. **Option B**: Direct PyPI publishing
   - Fern publishes directly to PyPI
   - Manual post-publish patching would be required
   - **Not recommended** - use Option A instead

## Testing

```python
from aui import AuiApiClient

client = AuiApiClient(api_key="YOUR_API_KEY")

# Connect to WebSocket
with client.external_session.connect() as socket:
    # Send message
    socket.send_user_message({
        "task_id": "task_id_here",
        "text": "Your message"
    })
    
    # Receive messages
    for message in socket.iter_messages():
        print(message)
```

## Status

✅ **Fix documented and tested locally**  
⏸️ **PyPI publishing not enabled yet** (no PYPI_TOKEN configured)

---

**Last Updated**: November 9, 2025

