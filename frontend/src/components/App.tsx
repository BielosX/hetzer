import * as React from "react";
import axios from "axios";
import { Route, BrowserRouter } from "react-router-dom";

import { BooksView } from "./BooksView"
import { Navbar } from "./Navbar"
import { NavbarButton } from "./NavbarButton"
import { BooksForm } from "./BooksForm"

const Main = (props) => {
    return (
        <div className="container-fluid">
            <div className="row">{props.children}</div>
        </div>
    );
}

export const App = (props) => {
    return (
            <BrowserRouter>
                <div>
                    <Navbar>
                        <NavbarButton link="/">Home</NavbarButton>
                        <NavbarButton link="/books">Books</NavbarButton>
                        <NavbarButton link="/addBook">Add book</NavbarButton>
                    </Navbar>
                    <Main>
                        <Route path="/books" exact={true} component={BooksView} />
                        <Route path="/addBook" exact={true} component={BooksForm} />
                    </Main>
                </div>
            </BrowserRouter>
    );
}

