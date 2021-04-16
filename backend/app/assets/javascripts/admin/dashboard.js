Admin.Dashboard.Main = function () {
    this.init = function () {
        google.charts.load('current', {'packages': ['corechart']});
        google.charts.setOnLoadCallback(this.drawCharts);
    };

    this.drawCharts = function () {
        (new Admin.Dashboard.SimpleLineChart({
            name: 'payment_orders_by_days',
            url: 'dashboard/payment_orders_by_days'
        })).init();
    };
};

Admin.Dashboard.SimpleLineChart = class {
    constructor(args) {
        this.rows = [];
        this.url = '/admin/' + (args.url || args.name);
        this.wrapperId = args.name + '_line_chart';
        this.formId = args.name + '_form';

        this.columns = [
            ['datetime', 'date'],
            ['number', 'value'],
            {type: 'number', role: 'annotation'}
        ];

        this.options = {
            legend: {position: 'none'},
            hAxis: {format: 'd.MM.yy HH:mm'}
        };

        if (args.columns) {
            this.columns = args.columns
        }

        if (args.options) {
            jQuery.extend(this.options, args.options);
        }

        this.ajaxComplete = this.ajaxComplete.bind(this)
    }

    init(query) {
        var queryString = query || '';

        if (this.formId) {
            var self = this;
            var inputs = $('#' + this.formId).find('.datepicker');

            inputs.change(function () {
                self.perform(inputs.serialize() + '&' + queryString);
            });
        }

        this.perform(queryString);
    };

    perform(params) {
        var data = params || {};

        $.ajax({
            url: this.url,
            data: data,
            dataType: 'json',
            success: this.ajaxComplete
        });
    };

    ajaxComplete(response) {
        if (response.rows !== undefined && response.rows.columns !== undefined) {
            this.columns = response.rows.columns;
            this.rows = response.rows.rows;
        } else {
            this.rows = response.rows;
        }

        this.updateTotal(response.total);
        this.normalizeRows();
        this.render();
    };

    updateTotal(total) {
        var id = ('#' + this.formId).replace('_form', '_total');

        $(id).text('Total: ' + total)
    }

    normalizeRows() {
        this.rows.forEach(function (part, index, theArray) {
            var time = part[0];
            var time = new Date(time);
            var time = new Date(time.getUTCFullYear(), time.getUTCMonth(), time.getUTCDate(), time.getUTCHours(), time.getUTCMinutes(), time.getUTCSeconds());
            theArray[index][0] = new Date(time);
        });
    };

    render() {
        var chart = new google.visualization.LineChart(document.getElementById(this.wrapperId));
        var data = new google.visualization.DataTable();

        this.columns.forEach(function (column) {
            if (column instanceof Array) {
                data.addColumn(column[0], column[1]);
            } else {
                data.addColumn(column);
            }
        });

        data.addRows(this.rows);

        chart.draw(data, this.options);
    };
};