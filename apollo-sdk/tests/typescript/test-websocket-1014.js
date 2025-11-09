import { AuiApiClient } from '@aui.io/apollo-sdk';

const API_KEY = 'API_KEY_01K92N5BD5M7239VRK7YTK4Y6N';
const TASK_ID = '6909127a8b91758e2d2f4ff9';

async function testWebSocket() {
    console.log('🧪 Testing WebSocket with v1.0.14\n');
    
    const client = new AuiApiClient({
        apiKey: API_KEY,
    });

    try {
        console.log('🔌 Connecting to WebSocket...\n');
        const socket = await client.externalSession.connect({ debug: true });
        
        socket.on('open', () => {
            console.log('✅ WebSocket Connected!\n');
            console.log('📤 Sending message...');
            socket.send('user_message', {
                task_id: TASK_ID,
                text: "I am looking for a built-in microwave with at least 20 liters capacity"
            });
        });

        socket.on('message', (eventType, data) => {
            console.log(`📨 Received: ${eventType}`);
        });

        socket.on('final_message', (data) => {
            console.log('✅ WebSocket Test Complete!');
            socket.close();
            process.exit(0);
        });

        socket.on('error', (error) => {
            console.error('❌ WebSocket Error:', error);
            process.exit(1);
        });

        setTimeout(() => {
            console.log('⏱️  Timeout - closing');
            socket.close();
            process.exit(0);
        }, 30000);

    } catch (error) {
        console.error('❌ WebSocket Connection Error:', error.message);
        process.exit(1);
    }
}

testWebSocket();
