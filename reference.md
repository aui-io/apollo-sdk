# Reference
## ControllerApi
<details><summary><code>client.controllerApi.<a href="/src/api/resources/controllerApi/client/Client.ts">listUserTasks</a>({ ...params }) -> Apollo.ListExternalTasksResponse</code></summary>
<dl>
<dd>

#### 🔌 Usage

<dl>
<dd>

<dl>
<dd>

```typescript
await client.controllerApi.listUserTasks({
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

**request:** `Apollo.ListUserTasksRequest` 
    
</dd>
</dl>

<dl>
<dd>

**requestOptions:** `ControllerApi.RequestOptions` 
    
</dd>
</dl>
</dd>
</dl>


</dd>
</dl>
</details>

<details><summary><code>client.controllerApi.<a href="/src/api/resources/controllerApi/client/Client.ts">createTask</a>({ ...params }) -> Apollo.CreateExternalTaskResponse</code></summary>
<dl>
<dd>

#### 🔌 Usage

<dl>
<dd>

<dl>
<dd>

```typescript
await client.controllerApi.createTask({
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

**requestOptions:** `ControllerApi.RequestOptions` 
    
</dd>
</dl>
</dd>
</dl>


</dd>
</dl>
</details>

<details><summary><code>client.controllerApi.<a href="/src/api/resources/controllerApi/client/Client.ts">getTaskMessages</a>(taskId) -> Apollo.ExternalTaskMessage[]</code></summary>
<dl>
<dd>

#### 🔌 Usage

<dl>
<dd>

<dl>
<dd>

```typescript
await client.controllerApi.getTaskMessages("task_id");

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

**requestOptions:** `ControllerApi.RequestOptions` 
    
</dd>
</dl>
</dd>
</dl>


</dd>
</dl>
</details>

<details><summary><code>client.controllerApi.<a href="/src/api/resources/controllerApi/client/Client.ts">sendMessage</a>({ ...params }) -> Apollo.ExternalTaskMessage</code></summary>
<dl>
<dd>

#### 🔌 Usage

<dl>
<dd>

<dl>
<dd>

```typescript
await client.controllerApi.sendMessage({
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

**requestOptions:** `ControllerApi.RequestOptions` 
    
</dd>
</dl>
</dd>
</dl>


</dd>
</dl>
</details>
