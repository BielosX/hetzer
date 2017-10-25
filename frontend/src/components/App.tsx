import * as React from "react";
import axios from "axios";

import { Filter } from "./Filter";
import { BooksList } from "./BooksList"
import { Navbar } from "./Navbar"
import { NavbarButton } from "./NavbarButton"
import { SearchInput } from "./SearchInput"

const LeftPanel = (props) => {
    return (
        <div className="col-sm-3 col-md-2 sidebar">
            <ul className="nav nav-sidebar">
                {props.children}
            </ul>
        </div>
    );
}

const CenterPanel = (props) => {
    return (
        <div className="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">{props.children}</div>
    );
}

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
        this.state = {books: [], filteredBooks: []};
        this.onFiltersChange = this.onFiltersChange.bind(this);
    }

    componentDidMount() {
        axios.get('books')
        .then((response) => {
            this.setState({
                books: response.data,
                filteredBooks: response.data
            });
        })
        .catch((error) => {
            console.log(error);
        });
    }

    onFiltersChange(activeFilters) {
        var books = this.state.books;
        if (activeFilters.length > 0) {
            this.setState({
                ...this.state,
                filteredBooks: books.filter(book => activeFilters.includes(book.genere))
            });
        }
        else {
            this.setState({
                ...this.state,
                filteredBooks: books
            });
        }
    }

    render() {
        return (
            <div>
                <Navbar>
                    <NavbarButton>Home</NavbarButton>
                </Navbar>
                <Main>
                    <LeftPanel>
                        <SearchInput placeholder="Search" />
                        <Filter onFiltersChange={this.onFiltersChange} filters={this.state.books.map(book => book.genere)} />
                    </LeftPanel>
                    <CenterPanel>
                        <h1 className="page-header">Books</h1>
                        <BooksList books={this.state.filteredBooks} />
                    </CenterPanel>
                </Main>
            </div>
        );
    }
}
