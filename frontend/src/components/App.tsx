import * as React from "react";

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
        <div className="col-sm-3 sidebar">
            <ul className="nav nav-sidebar">
                {props.children}
            </ul>
        </div>
    );
}

const CenterPanel = (props) => {
    return (
        <div className="col-sm-9 col-sm-offset-3 main">{props.children}</div>
    );
}

const SearchInput = (props) => {
    return (
        <li>
            <form>
                <div className="input-group">
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

export const App = () => {
    return (
        <div>
            <Navbar>
                <NavbarButton>Home</NavbarButton>
            </Navbar>
            <Main>
                <LeftPanel>
                    <SearchInput placeholder="Search" />
                    <li className="active">
                        <a>Fantasy</a>
                    </li>
                </LeftPanel>
                <CenterPanel>
                    <h1 className="page-header">Books</h1>
                </CenterPanel>
            </Main>
        </div>
    );
}
