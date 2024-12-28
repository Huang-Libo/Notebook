# JavaScript INBOX

## Tagged template literals

Tagged template literals are a feature in JavaScript that allow you to customize the processing of template literals (strings enclosed by backticks \`). A tagged template lets you use a function (called a tag function) to interpret and process the template literal, giving you control over its output.

Syntax

```javascript
tagFunction`template literal text`;
```

- `tagFunction`: A function that processes the template literal.
- The function receives the literal strings and the values of the interpolated expressions as arguments.

 The tag function is called with:

- **First Argument**: An array of literal string parts.
- **Remaining Arguments**: Values of the interpolated expressions.

```javascript
function highlight(strings, ...values) {
  return strings.reduce((result, str, i) => {
    return `${result}${str}<b>${values[i] || ''}</b>`;
  }, '');
}

const name = 'John';
const age = 30;

const result = highlight`Hello, my name is ${name}, and I am ${age} years old.`;
console.log(result);
// Output: "Hello, my name is <b>John</b>, and I am <b>30</b> years old."
```

The first argument `strings`:

```javascript
[
  "Hello, my name is ",
  ", and I am ",
  " years old.",
]
```

Remaining arguments `values`:

```javascript
[
  "John",
  30,
]
```


