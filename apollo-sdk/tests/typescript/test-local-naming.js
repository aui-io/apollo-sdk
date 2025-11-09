import { ApolloClient } from '../../generated-sdks/typescript/index.ts';

console.log('✅ ApolloClient imported successfully!');
console.log('Type:', typeof ApolloClient);

const client = new ApolloClient({
    baseUrl: 'https://api-staging.internal-aui.io/ia-controller',
    apiKey: 'test'
});

console.log('✅ Client created successfully!');
console.log('Client properties:', Object.keys(client));
console.log('Has externalApis:', 'externalApis' in client);
console.log('Has externalSession:', 'externalSession' in client);
