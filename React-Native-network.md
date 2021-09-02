# Networking

- [官方文档](https://reactnative.dev/docs/network)

## Fetch

> 详细介绍可查看 MDN 的文档：[Using Fetch](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch)

在 React Native 中可使用 [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) 发送网络请求。

### Making requests

示例：

```javascript
fetch('https://mywebsite.com/mydata.json');
```

Fetch 也提供了一个可选的参数，来设置 HTTP Method 、 header 、 body 等。完整的参数列表可参考 [Fetch Request docs](https://developer.mozilla.org/en-US/docs/Web/API/Request)

```javascript
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

## Handling the response

网络本质上是一种异步操作。`Fetch` 方法将返回一个 [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) ，它使异步代码的编写变得简单:

```javascript
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

```javascript
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

```javascript
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
