import * as React from "react";

export const TextBox = (props) => {
    return(
        <div className="form-group">
            <label htmlFor={props.id}>{props.label}</label>
            <input type={props.type} name={props.name} className="form-control" id={props.id} onChange={props.onChange}/>
        </div>
    );
}
