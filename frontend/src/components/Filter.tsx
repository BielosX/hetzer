import * as React from "react";

import {FilterOption} from "./FilterOption";

function removeDuplicates(array) {
    return Array.from(new Set(array));
}

export class Filter extends React.Component<any,any> {
    constructor(props) {
        super(props);
        this.state = {filters: []};
        this.onCheckboxClick = this.onCheckboxClick.bind(this);
    }

    componentWillReceiveProps(nextProps) {
        var currentFilters = new Map(this.state.filters.map(filter => [filter.filter, filter.applied]));
        var values = removeDuplicates(nextProps.filters).map(value => {
            if (currentFilters.has(value)) {
                return {filter: value, applied: currentFilters.get(value)};
            }
            return {filter: value, applied: false};
        });
        this.setState({
            filters: values
        });
    }

    onCheckboxClick(filterType) {
        var newState = this.state.filters.map(filter => {
            if (filter.filter === filterType) {
                return ({...filter, applied: !filter.applied});
            }
            return filter;
        });
        this.setState({
            filters: newState
        }, function() {
            this.props.onFiltersChange(this.state.filters.filter(f => f.applied).map(f => f.filter));
        });
    }

    render() {
        return (
            <div>
                {this.state.filters.map((filter, index) => (
                    <FilterOption key={index} value={filter.filter} onClick={this.onCheckboxClick} filterName={filter.filter} checked={filter.applied} /> ))}
            </div>
        );
    }
}

