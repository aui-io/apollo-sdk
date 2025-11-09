# Reference
## ExternalApis
<details><summary><code>client.externalApis.<a href="/src/api/resources/externalApis/client/Client.ts">getTasksByUserId</a>({ ...params }) -> Apollo.ListExternalTasksResponse</code></summary>
<dl>
<dd>

#### 🔌 Usage

<dl>
<dd>

<dl>
<dd>

```typescript
await client.externalApis.getTasksByUserId({
    user_id: "user_id",
    page: 1,
    size: 1
});

```
</dd>
</dl>
</dd>
</dl>

#### ⚙️ Parameters

<dl>
<dd>

<dl>
<dd>

**request:** `Apollo.GetTasksByUserIdApiV1ExternalTasksGetRequest` 
    
</dd>
</dl>

<dl>
<dd>

**requestOptions:** `ExternalApis.RequestOptions` 
    
</dd>
</dl>
</dd>
</dl>


</dd>
</dl>
</details>

<details><summary><code>client.externalApis.<a href="/src/api/resources/externalApis/client/Client.ts">task</a>({ ...params }) -> Apollo.CreateExternalTaskResponse</code></summary>
<dl>
<dd>

#### 🔌 Usage

<dl>
<dd>

<dl>
<dd>

```typescript
await client.externalApis.task({
    user_id: "user_id"
});

```
</dd>
</dl>
</dd>
</dl>

#### ⚙️ Parameters

<dl>
<dd>

<dl>
<dd>

**request:** `Apollo.CreateExternalTaskRequest` 
    
</dd>
</dl>

<dl>
<dd>

**requestOptions:** `ExternalApis.RequestOptions` 
    
</dd>
</dl>
</dd>
</dl>


</dd>
</dl>
</details>

<details><summary><code>client.externalApis.<a href="/src/api/resources/externalApis/client/Client.ts">getTaskMessages</a>(taskId) -> Apollo.ExternalTaskMessage[]</code></summary>
<dl>
<dd>

#### 🔌 Usage

<dl>
<dd>

<dl>
<dd>

```typescript
await client.externalApis.getTaskMessages("task_id");

```
</dd>
</dl>
</dd>
</dl>

#### ⚙️ Parameters

<dl>
<dd>

<dl>
<dd>

**taskId:** `string` 
    
</dd>
</dl>

<dl>
<dd>

**requestOptions:** `ExternalApis.RequestOptions` 
    
</dd>
</dl>
</dd>
</dl>


</dd>
</dl>
</details>

<details><summary><code>client.externalApis.<a href="/src/api/resources/externalApis/client/Client.ts">message</a>({ ...params }) -> Apollo.ExternalTaskMessage</code></summary>
<dl>
<dd>

#### 🔌 Usage

<dl>
<dd>

<dl>
<dd>

```typescript
await client.externalApis.message({
    is_external_api: true,
    task_id: "task_id",
    text: "text"
});

```
</dd>
</dl>
</dd>
</dl>

#### ⚙️ Parameters

<dl>
<dd>

<dl>
<dd>

**request:** `Apollo.SubmitExternalMessageRequest` 
    
</dd>
</dl>

<dl>
<dd>

**requestOptions:** `ExternalApis.RequestOptions` 
    
</dd>
</dl>
</dd>
</dl>


</dd>
</dl>
</details>
