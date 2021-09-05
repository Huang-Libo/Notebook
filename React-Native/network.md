# React Native：网络

- [官方文档](https://reactnative.dev/docs/network)

## Fetch

> 详细介绍可查看 MDN 的文档：[Using Fetch](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch)

在 React Native 中可使用 [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) 发送网络请求。

### Making requests

示例：

```jsx
fetch('https://mywebsite.com/mydata.json');
```

Fetch 也提供了一个可选的参数来设置 HTTP Method 、 Header 、 Body 等。完整的参数列表可参考 [Fetch Request docs](https://developer.mozilla.org/en-US/docs/Web/API/Request) 。

```jsx
fetch('https://mywebsite.com/endpoint/', {
  method: 'POST',
  headers: {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    firstParam: 'yourValue',
    secondParam: 'yourOtherValue'
  })
});
```

### Handling the response

网络本质上是一种异步操作。`Fetch` 方法将返回一个 [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) ，它使异步代码的编写变得简单:

```jsx
const getMoviesFromApi = () => {
  return fetch('https://reactnative.dev/movies.json')
    .then((response) => response.json())
    .then((json) => {
      return json.movies;
    })
    .catch((error) => {
      console.error(error);
    });
};
```

你也可以在 React Native 中使用 `async` / `await` 语法：

```jsx
const getMoviesFromApiAsync = async () => {
  try {
    const response = await fetch(
      'https://reactnative.dev/movies.json'
    );
    const json = await response.json();
    return json.movies;
  } catch (error) {
    console.error(error);
  }
};
```

**可运行的示例**：

```jsx
import React, { useEffect, useState } from 'react';
import { ActivityIndicator, FlatList, Text, View, SafeAreaView } from 'react-native';

export default App = () => {
  const [isLoading, setLoading] = useState(true);
  const [data, setData] = useState([]);

  const getMovies = async () => {
     try {
      const response = await fetch('https://reactnative.dev/movies.json');
      const json = await response.json();
      setData(json.movies);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    getMovies();
  }, []);

  return (
    <SafeAreaView style={{ flex: 1, padding: 24 , left: 10, top: 10 }}>
      {isLoading ? <ActivityIndicator/> : (
        <FlatList
          data={data}
          keyExtractor={({ id }, index) => id}
          renderItem={({ item }) => (
            <Text>{item.id}, {item.title}, {item.releaseYear}</Text>
          )}
        />
      )}
    </SafeAreaView>
  );
};
```

## Using Other Networking Libraries

[XMLHttpRequest API](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) 是内建在 React Native 里的。这意味着您可以使用依赖于它的第三方库，如 [axios](https://github.com/mzabriskie/axios) ，或者直接使用 `XMLHttpRequest` ：

> The security model for XMLHttpRequest is different than on web as there is no concept of [CORS](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing) in native apps.

```jsx
var request = new XMLHttpRequest();
request.onreadystatechange = (e) => {
  if (request.readyState !== 4) {
    return;
  }

  if (request.status === 200) {
    console.log('success', request.responseText);
  } else {
    console.warn('error');
  }
};

request.open('GET', 'https://mywebsite.com/endpoint/');
request.send();
```

## WebSocket Support

React Native 也支持 [WebSockets](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket) （一种在单个 TCP 连接上提供全双工通信通道的协议）。

```jsx
var ws = new WebSocket('ws://host.com/path');

ws.onopen = () => {
  // connection opened
  ws.send('something'); // send a message
};

ws.onmessage = (e) => {
  // a message was received
  console.log(e.data);
};

ws.onerror = (e) => {
  // an error occurred
  console.log(e.message);
};

ws.onclose = (e) => {
  // connection closed
  console.log(e.code, e.reason);
};
```

## Security

<https://reactnative.dev/docs/security>
