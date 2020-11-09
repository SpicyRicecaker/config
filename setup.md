# Svelte VSCode Setup

Use degit to clone a new project

```bash
npx degit sveltejs/template newProject123
cd newProject123
```

## (Optional) Typescript

You can install support at this stage with

```bash
node scripts/setupTypeScript.js
```

Finally, initalize project

```bash
yarn install
```

## Installing the VSCode Svelte extension

Search for `Svelte for VS Code` extension in vscode and install.

## (Optional) Eslint

Install eslint

```bash
yarn add eslint
```

Next, make an `eslintrc.js` file

```bash
yarn eslint --init
```

To get live linting we need to first install the `ESLint` extension in VSCode.

Then, in workspace settings (accessed by `ctrl+shift+p` and searching up workspace settings) add

```json
  "eslint.validate": ["svelte"]
```

### (Optional) Typescript Support

```bash
yarn add -D @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

- `@typescript-eslint/parser` allows eslint to lint typescript code
- `@typescript-eslint/eslint-plugin` adds rules to resolve eslint and typescript conflicts

In the `.eslintrc.js` file, make sure that

```js
parser: "@typescript-eslint/parser", // we're using the right parser
extends: ["plugin:@typescript-eslint/recommended]", // we're resolving conflicts
```

### (Optional) Prettier Support

```bash
yarn add -D prettier eslint-config-prettier eslint-plugin-prettier
```

- `prettier` is vital
- `eslint-config-prettier` disables conflicting rules
- `eslint-plugin-prettier` lints prettier errors

> As of 9/12/20 I think that the best solution is just to say
>
> ```json
> "[svelte]": {
> "editor.defaultFormatter": "svelte.svelte-vscode"
> }
> ```

Finally, in the `eslintrc.js` file make sure to extend these plugins

```js
'prettier/@typescript-eslint', 'plugin:prettier/recommended';
```
