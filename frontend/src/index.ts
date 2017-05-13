import axios from 'axios';

axios.defaults.baseURL = "http://localhost:8000";

class User {
    private _name: string;
    private _email: string;

    public get name() { return this._name; }
    public get email() { return this._email; }

    constructor(name: string, email: string) {
        this._name = name;
        this._email = email;
    }
}

axios.post('/users', {name: "Tomasz", email: "tomasz@tomasz.com"})
    .then(() => {
    axios.get('/users')
        .then((response) => {
            console.log(response.data);
            let users: [User] = response.data;
            let emails = users.map(user => { return user.email; });
            console.log(emails);
        })
        .catch((error) => {console.log(error);});
    })
    .catch((error) => {console.log(error);});

