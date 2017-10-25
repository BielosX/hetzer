import * as React from "react";
import { Link } from "react-router-dom";

export class NavbarButton extends React.Component<any,any> {
    constructor(props) {
        super(props);
        this.state = {isActive: false};
    }

    render() {
        const isActive = this.state.isActive;
        if (isActive) {
            return (
                <li className="active">
                    <Link to={this.props.link}>
                        {this.props.children}
                    </Link>
                </li>
            );
        }
        else {
            return <li><Link to={this.props.link}>{this.props.children}</Link></li>
        }
    }
}
