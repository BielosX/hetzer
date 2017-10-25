import * as React from "react";

export const BooksList = (props) => {
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
