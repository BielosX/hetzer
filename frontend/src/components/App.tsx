import * as React from "react";

const Navbar = (props) => {
    return (
        <nav className="navbar navbar-inverse navbar-static-top">
            <div className="container">
                <div id="navbar" className="navbar-collapse collapse">
                    <ul className="nav navbar-nav">
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
        <div className="col-sm-4">{props.children}</div>
    );
}

const CenterPanel = (props) => {
    return (
        <div className="col-sm-8">{props.children}</div>
    );
}

const SearchInput = (props) => {
    return (
        <form>
            <div className="input-group">
            <input type="text" className="form-control" placeholder={props.placeholder}/>
            </div>
        </form>
    );
}

const Main = (props) => {
    return (
        <div className="container">
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
                </LeftPanel>
                <CenterPanel>
                </CenterPanel>
            </Main>
        </div>
    );
}
