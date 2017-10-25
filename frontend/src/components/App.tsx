import * as React from "react";
import axios from "axios";

import { BooksView } from "./BooksView"
import { Navbar } from "./Navbar"
import { NavbarButton } from "./NavbarButton"

const Main = (props) => {
    return (
        <div className="container-fluid">
            <div className="row">{props.children}</div>
        </div>
    );
}

export const App = (props) => {
    return (
            <div>
                <Navbar>
                    <NavbarButton>Home</NavbarButton>
                </Navbar>
                <Main>
                    <BooksView />
                </Main>
            </div>
    );
}
