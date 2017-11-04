import * as React from "react";
import axios from "axios";

import {TextBox} from "./TextBox";
import {HetzerConnector} from "../HetzerConnector";

export class BooksForm extends React.Component<any,any> {

    constructor(props) {
        super(props);
        this.state = {
            title: '',
            author: '',
            isbn: '',
            genere: '',
            published: '',
            quantity: 0,
            left: 0
        };
        this.onSubmit = this.onSubmit.bind(this);
        this.onChange = this.onChange.bind(this);
    }

    onSubmit(event) {
        event.preventDefault();
        this.props.connector.postBooks(this.state)
        .then((response) => {
            console.log(response);
        })
        .catch((error) => {
            console.log(error);
        });
    }

    onChange(event) {
        const target = event.target;
        const name = target.name;
        var value;

        if (name === "quantity" || name === "left") {
            value = parseInt(target.value)
        }
        else {
            value = target.value;
        }

        this.setState({
            [name]: value
        });
    }

    render() {
        return(
            <div className="container">
                <div className="row">
                    <div className="col-md-3 .bg-light">&nbsp;</div>
                    <div className="col-md-3 main">
                        <form onSubmit={this.onSubmit} id="addBookForm">
                            <TextBox label="Title" id="bookTitle" type="text" name="title" onChange={this.onChange} />
                            <TextBox label="Author" id="bookAuthor" type="text" name="author" onChange={this.onChange} />
                            <TextBox label="ISBN" id="bookIsbn" type="text" name="isbn" onChange={this.onChange} />
                            <TextBox label="Genere" id="bookGenere" type="text" name="genere" onChange={this.onChange} />
                            <TextBox label="Publish date" id="bookPublished" type="text" name="published" onChange={this.onChange} />
                            <TextBox label="Quantity" id="bookQuantity" type="number" name="quantity" onChange={this.onChange} />
                            <TextBox label="Left in stock" id="bookLeft" type="number" name="left" onChange={this.onChange} />
                            <input type="submit" className="btn btn-primary" value="Save" />
                        </form>
                    </div>
                    <div className="col-md-3 .bg-light">&nbsp;</div>
                </div>
            </div>
        );
    }
}
