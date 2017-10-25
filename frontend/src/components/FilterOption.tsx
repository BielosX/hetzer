import * as React from "react";

export const FilterOption = (props) => {
    return (
        <li>
            <div className="input-group nav-search">
                <label>
                    <input type="checkbox" value={props.value} checked={props.checked} onClick={() => props.onClick(props.value)} />
                    {props.filterName}
                </label>
            </div>
        </li>
    );
}
