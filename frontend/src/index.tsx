import * as React from "react";
import * as ReactDOM from "react-dom";
import axios from 'axios';

import { Hello } from "./components/Hello";

ReactDOM.render(
    <Hello compiler="TypeScript" framework="React" />,
    document.getElementById("root")
);

