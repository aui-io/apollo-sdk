import { ApolloClient } from '@aui.io/apollo-sdk';

// Configuration
const API_KEY = process.env.API_KEY || 'API_KEY_01K92N5BD5M7239VRK7YTK4Y6N';
const TASK_ID = process.env.TASK_ID || '6909e075db7f4eff00486c73';
const BASE_URL = process.env.BASE_URL || 'https://api-staging.internal-aui.io/ia-controller';

async function testGetMessages() {
    console.log('🧪 Testing Get Messages Endpoint\n');
    console.log(`Base URL: ${BASE_URL}`);
    console.log(`Task ID: ${TASK_ID}\n`);

    // Initialize client with API key
    const client = new ApolloClient({
        baseUrl: BASE_URL,
        apiKey: API_KEY,
    });

    try {
        console.log('📡 Calling externalApis.getTaskMessages...\n');
        
        const result = await client.externalApis.getTaskMessages(TASK_ID);

        console.log('✅ Success! Response received:\n');
        console.log(JSON.stringify(result, null, 2));
        
        console.log('\n📊 Summary:');
        console.log(`   - Messages returned: ${result.length}`);
        
        if (result.length > 0) {
            console.log('\n📝 Sample message:');
            console.log(JSON.stringify(result[0], null, 2));
        }

    } catch (error) {
        console.error('❌ Error occurred:\n');
        if (error.statusCode) {
            console.error(`   Status Code: ${error.statusCode}`);
        }
        if (error.message) {
            console.error(`   Message: ${error.message}`);
        }
        if (error.body) {
            console.error(`   Body:`, error.body);
        }
        console.error('\nFull error:', error);
        process.exit(1);
    }
}

// Run the test
testGetMessages()
    .then(() => {
        console.log('\n✅ Test completed successfully!');
        process.exit(0);
    })
    .catch((error) => {
        console.error('\n❌ Test failed:', error);
        process.exit(1);
    });

