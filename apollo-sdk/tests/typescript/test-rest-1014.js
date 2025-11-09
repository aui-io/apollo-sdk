import { AuiApiClient } from '@aui.io/apollo-sdk';

const API_KEY = 'API_KEY_01K92N5BD5M7239VRK7YTK4Y6N';
const TASK_ID = '6909e075db7f4eff00486c73';
const BASE_URL = 'https://api-staging.internal-aui.io/ia-controller';

async function testREST() {
    console.log('🧪 Testing REST API with v1.0.14\n');
    
    const client = new AuiApiClient({
        baseUrl: BASE_URL,
        apiKey: API_KEY,
    });

    try {
        console.log('📡 Calling externalApis.getTaskMessages...\n');
        const result = await client.externalApis.getTaskMessages(TASK_ID);
        console.log('✅ REST API Success!');
        console.log(`   Messages returned: ${result.length}`);
        process.exit(0);
    } catch (error) {
        console.error('❌ REST API Error:', error.message);
        process.exit(1);
    }
}

testREST();
