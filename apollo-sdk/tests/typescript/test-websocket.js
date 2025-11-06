import { AuiApiClient } from '@aui.io/apollo-sdk';

// Configuration from environment or defaults
const API_KEY = process.env.API_KEY || 'your-api-key-here';
const TASK_ID = process.env.TASK_ID || '6909127a8b91758e2d2f4ff9';
const MESSAGE_TEXT = process.env.MESSAGE_TEXT || 'I am looking for a built-in microwave with at least 20 liters capacity';

// Test message payload
const TEST_MESSAGE = {
    task_id: TASK_ID,
    text: MESSAGE_TEXT
};

async function testWebSocket() {
    console.log('🧪 Testing WebSocket Connection with AUI Apollo SDK\n');
    console.log(`Task ID: ${TASK_ID}`);
    console.log(`Message: ${MESSAGE_TEXT}\n`);

    // Initialize SDK client with API key
    const client = new AuiApiClient({
        apiKey: API_KEY,
        // Uses default staging environment for WebSocket
    });

    try {
        console.log('🔌 Connecting to WebSocket via SDK...\n');
        
        // Connect to WebSocket using SDK
        const socket = await client.externalSession.connect({
            debug: true,
            reconnectAttempts: 3
        });

        console.log(socket);
        
        console.log('✅ WebSocket connection initiated\n');

        // Track streaming state
        let streamingText = '';
        let messageCount = 0;

        // Register event handlers
        socket.on('open', () => {
            console.log('✅ WebSocket opened successfully!\n');
            console.log('📤 Sending message...\n');
            
            try {
                socket.sendUserMessage(TEST_MESSAGE);
                console.log('✅ Message sent:\n');
                console.log(JSON.stringify(TEST_MESSAGE, null, 2));
                console.log('\n⏳ Waiting for responses...\n');
            } catch (error) {
                console.error('❌ Error sending message:', error);
            }
        });

        socket.on('message', (message) => {
            messageCount++;
            console.log(`\n📨 Message #${messageCount} received:`);
            
            // Handle different message types
            if ('channel' in message && 'data' in message) {
                // StreamingUpdatePayload
                console.log('   Type: Streaming Update');
                console.log(`   Event: ${message.channel.event_name}`);
                if (message.data && 'text' in message.data) {
                    streamingText += message.data.text;
                    console.log(`   Text chunk: "${message.data.text}"`);
                    console.log(`   Accumulated text length: ${streamingText.length} characters`);
                }
                if (message.scope?.context) {
                    console.log(`   Context:`, message.scope.context);
                }
            } else if ('text' in message && 'sender' in message && 'receiver' in message) {
                // FinalMessagePayload
                console.log('   Type: Final Message');
                console.log(`   ID: ${message.id}`);
                console.log(`   Sender: ${message.sender}`);
                console.log(`   Receiver: ${message.receiver}`);
                console.log(`   Complete text: "${message.text}"`);
                
                if (message.cards && message.cards.length > 0) {
                    console.log(`\n   📦 Product Cards (${message.cards.length}):`);
                    message.cards.forEach((card, index) => {
                        console.log(`\n   Card ${index + 1}:`);
                        console.log(`      Title: ${card.title}`);
                        console.log(`      Description: ${card.description}`);
                        if (card.parameters && card.parameters.length > 0) {
                            console.log(`      Parameters: ${card.parameters.length}`);
                            card.parameters.forEach(param => {
                                console.log(`         - ${param.name}: ${param.value}`);
                            });
                        }
                    });
                }
                
                if (message.followup_suggestions && message.followup_suggestions.length > 0) {
                    console.log(`\n   💡 Follow-up Suggestions (${message.followup_suggestions.length}):`);
                    message.followup_suggestions.forEach((suggestion, index) => {
                        console.log(`      ${index + 1}. ${suggestion}`);
                    });
                }
                
                console.log('\n✅ Conversation complete! Closing connection...');
                socket.close();
            } else if ('error' in message) {
                // ErrorMessagePayload
                console.log('   Type: Error Message');
                console.log(`   Error: ${message.error}`);
                console.log(`   Details: ${JSON.stringify(message, null, 2)}`);
            } else {
                console.log('   Type: Unknown');
                console.log(`   Data: ${JSON.stringify(message, null, 2)}`);
            }
        });

        socket.on('error', (error) => {
            console.error('\n❌ WebSocket error:', error.message);
            console.error('Full error:', error);
        });

        socket.on('close', (event) => {
            console.log('\n🔌 WebSocket closed');
            console.log(`   Code: ${event.code}`);
            console.log(`   Reason: ${event.reason || 'No reason provided'}`);
            
            console.log('\n📊 Summary:');
            console.log(`   - Total messages received: ${messageCount}`);
            console.log(`   - Streaming text length: ${streamingText.length} characters`);
            
            if (event.code === 1000) {
                console.log('\n✅ Connection closed normally');
                process.exit(0);
            } else if (event.code === 1008) {
                console.log('\n⚠️  Connection closed due to authentication or policy violation');
                process.exit(1);
            } else if (event.code === 1011) {
                console.log('\n❌ Connection closed due to internal server error');
                process.exit(1);
            } else {
                console.log(`\n⚠️  Connection closed with code ${event.code}`);
                process.exit(1);
            }
        });

        // Wait for the socket to open
        await socket.waitForOpen();

    } catch (error) {
        console.error('❌ Error occurred:\n');
        if (error.statusCode) {
            console.error(`   Status Code: ${error.statusCode}`);
        }
        if (error.message) {
            console.error(`   Message: ${error.message}`);
        }
        if (error.code) {
            console.error(`   Code: ${error.code}`);
        }
        console.error('\nFull error:', error);
        process.exit(1);
    }
}

// Run the test with timeout
const timeout = setTimeout(() => {
    console.error('\n⏰ Test timeout after 60 seconds');
    process.exit(1);
}, 60000);

testWebSocket()
    .then(() => {
        clearTimeout(timeout);
        console.log('\n✅ Test completed successfully!');
    })
    .catch((error) => {
        clearTimeout(timeout);
        console.error('\n❌ Test failed:', error);
        process.exit(1);
    });

