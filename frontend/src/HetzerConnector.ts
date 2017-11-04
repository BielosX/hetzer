import axios from "axios";

export class HetzerConnector {

    token: string;

    constructor() {
        this.token = " ";
        this.getBooks = this.getBooks.bind(this);
        this.postLogin = this.postLogin.bind(this);
    }

    getBooks() {
        return axios.get('books', {headers: {Authorization: "Bearer " + this.token}})
        .then(response => {
            var token = response.headers['x-auth-token'];
            this.token = token;
            return Promise.resolve(response);
        })
        .catch(error => {
            return Promise.reject(error);
        });
    }

    postLogin(login, passwd) {
        return axios.post('login', {username: login, password: passwd})
        .then(response => {
            var token = response.headers['x-auth-token'];
            this.token = token;
            return Promise.resolve(response);
        })
        .catch(error => {
            return Promise.reject(error);
        });
    }

    postBooks(books) {
        return axios.post('books', books, {headers: {Authorization: "Bearer " + this.token}})
        .then(response => {
            var token = response.headers['x-auth-token'];
            this.token = token;
            return Promise.resolve(response);
        })
        .catch(error => {
            return Promise.reject(error);
        });
    }
}
