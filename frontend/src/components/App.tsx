import * as React from "react";
import axios from "axios";
import { Route, BrowserRouter } from "react-router-dom";

import { BooksView } from "./BooksView"
import { Navbar } from "./Navbar"
import { NavbarButton } from "./NavbarButton"
import { BooksForm } from "./BooksForm"
import { HetzerConnector } from "../HetzerConnector"
import { Login } from "./Login"

const Main = (props) => {
    return (
        <div className="container-fluid">
            <div className="row">{props.children}</div>
        </div>
    );
}

export class App extends React.Component<any,any> {

    constructor(props) {
        super(props);
        this.state = { connector: new HetzerConnector() }
    }

    render() {
        return (
                <BrowserRouter>
                    <div>
                        <Navbar>
                            <NavbarButton link="/">Home</NavbarButton>
                            <NavbarButton link="/books">Books</NavbarButton>
                            <NavbarButton link="/addBook">Add book</NavbarButton>
                            <NavbarButton link="/login">Login</NavbarButton>
                        </Navbar>
                        <Main>
                            <Route path="/books" exact={true} render={() => <BooksView connector={this.state.connector} /> } />
                            <Route path="/login" exact={true} render={() => <Login connector={this.state.connector} /> } />
                            <Route path="/addBook" exact={true} render={() => <BooksForm connector={this.state.connector} />} />
                        </Main>
                    </div>
                </BrowserRouter>
        );
    }
}

