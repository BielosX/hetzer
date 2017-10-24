import * as React from "react";
import axios from "axios";

const Navbar = (props) => {
    return (
        <nav className="navbar navbar-inverse navbar-static-top">
            <div className="container">
                <div id="navbar" className="navbar-collapse collapse">
                    <ul className="nav navbar-nav navbar-right">
                        {props.children}
                    </ul>
                </div>
            </div>
        </nav>
    );
}

class NavbarButton extends React.Component<any,any> {
    constructor(props) {
        super(props);
        this.state = {isActive: false};
    }

    render() {
        const isActive = this.state.isActive;
        if (isActive) {
            return (
                <li className="active">
                        <a>{this.props.children}</a>
                </li>
            );
        }
        else {
            return <li><a>{this.props.children}</a></li>
        }
    }
}

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

const SearchInput = (props) => {
    return (
        <li>
            <form>
                <div className="input-group nav-search">
                    <input type="text" className="form-control" placeholder={props.placeholder}/>
                </div>
            </form>
        </li>
    );
}

const Main = (props) => {
    return (
        <div className="container-fluid">
            <div className="row">{props.children}</div>
        </div>
    );
}

const BooksList = (props) => {
    return (
        <table className="table">
            <thead>
                <tr>
                    <th scope="col">Title</th>
                    <th scope="col">Author</th>
                    <th scope="col">Genere</th>
                    <th scope="col">Published</th>
                    <th scope="col">In stock</th>
                </tr>
            </thead>
            <tbody>
            {props.books.map(book => (
                <tr key={book.id}>
                    <td>{book.title}</td>
                    <td>{book.author}</td>
                    <td>{book.genere}</td>
                    <td>{book.published}</td>
                    <td>{book.left}</td>
                </tr>
            ))}
            </tbody>
        </table>
    );
}

const FilterOption = (props) => {
    return (
        <li>
            <div className="input-group nav-search">
                <label>
                    <input type="checkbox" value={props.value} checked={props.checked} onClick={() => props.onClick(props.value)} />
                    {props.filterName}
                </label>
            </div>
        </li>
    );
}

function removeDuplicates(array) {
    return Array.from(new Set(array));
}

class Filter extends React.Component<any,any> {
    constructor(props) {
        super(props);
        this.state = {filters: []};
        this.onCheckboxClick = this.onCheckboxClick.bind(this);
    }

    componentWillReceiveProps(nextProps) {
        var currentFilters = new Map(this.state.filters.map(filter => [filter.filter, filter.applied]));
        var values = removeDuplicates(nextProps.filters).map(value => {
            if (currentFilters.has(value)) {
                return {filter: value, applied: currentFilters.get(value)};
            }
            return {filter: value, applied: false};
        });
        this.setState({
            filters: values
        });
    }

    onCheckboxClick(filterType) {
        var newState = this.state.filters.map(filter => {
            if (filter.filter === filterType) {
                return ({...filter, applied: !filter.applied});
            }
            return filter;
        });
        this.setState({
            filters: newState
        }, function() {
            this.props.onFiltersChange(this.state.filters.filter(f => f.applied).map(f => f.filter));
        });
    }

    render() {
        return (
            <div>
                {this.state.filters.map((filter, index) => (
                    <FilterOption key={index} value={filter.filter} onClick={this.onCheckboxClick} filterName={filter.filter} checked={filter.applied} /> ))}
            </div>
        );
    }
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
