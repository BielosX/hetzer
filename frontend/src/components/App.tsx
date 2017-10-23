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
                    <input type="checkbox" value={props.value} checked={props.checked} onClick={props.onClick} />
                    {props.filterName}
                </label>
            </div>
        </li>
    );
}

class Filter extends React.Component<any,any> {
    constructor(props) {
        super(props);
        this.state = {filters: []};
    }

    componentWillReceiveProps(nextProps) {
        var values = nextProps.filters.map(value => ({filter: value, applied: false}) );
        console.log(values);
        this.setState({
            filters: values
        });
    }

    render() {
        return (
            <div>
                {this.state.filters.map((filter, index) => (
                    <FilterOption key={index} value={filter.filter} filterName={filter.filter} checked={filter.applied} /> ))}
            </div>
        );
    }
}

export class App extends React.Component<any,any> {

    constructor(props) {
        super(props);
        this.state = {books: []};
    }

    componentDidMount() {
        axios.get('books')
        .then((response) => {
            this.setState({
                books: response.data
            });
        })
        .catch((error) => {
            console.log(error);
        });
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
                        <Filter filters={this.state.books.map(book => book.genere)} />
                    </LeftPanel>
                    <CenterPanel>
                        <h1 className="page-header">Books</h1>
                        <BooksList books={this.state.books} />
                    </CenterPanel>
                </Main>
            </div>
        );
    }
}
