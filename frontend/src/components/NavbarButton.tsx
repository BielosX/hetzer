import * as React from "react";

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
                        <a>{this.props.children}</a>
                </li>
            );
        }
        else {
            return <li><a>{this.props.children}</a></li>
        }
    }
}
