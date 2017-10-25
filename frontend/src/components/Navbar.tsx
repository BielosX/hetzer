import * as React from "react";

export const Navbar = (props) => {
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
