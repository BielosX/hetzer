import * as React from "react";

import {TextBox} from "./TextBox";

export class Login extends React.Component<any,any> {

    constructor(props) {
        super(props);
        this.state = {
            login: '',
            password: ''
        };
        this.onSubmit = this.onSubmit.bind(this);
        this.onChange = this.onChange.bind(this);
    }

    onChange(event) {
        const target = event.target;
        const name = target.name;
        var value;

        value = target.value;
        this.setState({
            [name]: value
        });
    }

    onSubmit(event) {
        event.preventDefault();
        this.props.connector.postLogin(this.state.login, this.state.password)
        .then((response) => {
            console.log(response);
        })
        .catch((error) => {
            console.log(error);
        });
    }

    render() {
        return (
            <div className="container">
                <div className="row">
                    <div className="col-md-3 .bg-light">&nbsp;</div>
                    <div className="col-md-3 main">
                        <form onSubmit={this.onSubmit} id="loginForm">
                            <TextBox label="Username" id="bookTitle" type="text" name="login" onChange={this.onChange} />
                            <TextBox label="Password" id="bookAuthor" type="password" name="password" onChange={this.onChange} />
                            <input type="submit" className="btn btn-primary" value="Login" />
                        </form>
                    </div>
                    <div className="col-md-3 .bg-light">&nbsp;</div>
                </div>
            </div>
        );
    }
}
