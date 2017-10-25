import * as React from "react";

export const SearchInput = (props) => {
    return (
        <li>
            <form>
                <div className="input-group nav-search">
                    <input type="text" className="form-control" placeholder={props.placeholder}/>
                </div>
            </form>
        </li>
    );
}
