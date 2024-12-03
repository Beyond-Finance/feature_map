document.addEventListener("DOMContentLoaded", function() {
  let abc_size_values = [];
  let lines_of_code_values = [];
  let cyclomatic_complexity_values = [];

  Object.keys(window.FEATURES).forEach(feature_name => {
    let feature_data = window.FEATURES[feature_name];
    let feature_row = document.createElement('tr');

    let feature_name_td = document.createElement('td');
    feature_name_td.classList.add('white-space-nowrap', 'py-5', 'px-4', 'text-left', 'text-sm', 'font-medium', 'text-gray-800');
    feature_name_td.appendChild(document.createTextNode(feature_name));
    feature_row.appendChild(feature_name_td);

    let abc_size_td = document.createElement('td');
    abc_size_td.classList.add('white-space-nowrap', 'py-5', 'px-4', 'text-sm', 'text-gray-700');
    abc_size_td.appendChild(document.createTextNode(feature_data.metrics.abc_size));
    feature_row.appendChild(abc_size_td);

    let lines_of_code_td = document.createElement('td');
    lines_of_code_td.classList.add('white-space-nowrap', 'py-5', 'px-4', 'text-sm', 'text-gray-700');
    lines_of_code_td.appendChild(document.createTextNode(feature_data.metrics.lines_of_code));
    feature_row.appendChild(lines_of_code_td);

    let cyclomatic_complexity_td = document.createElement('td');
    cyclomatic_complexity_td.classList.add('white-space-nowrap', 'py-5', 'px-4', 'text-sm', 'text-gray-700');
    cyclomatic_complexity_td.appendChild(document.createTextNode(feature_data.metrics.cyclomatic_complexity));
    feature_row.appendChild(cyclomatic_complexity_td);

    let file_count_td = document.createElement('td');
    file_count_td.classList.add('white-space-nowrap', 'py-5', 'px-4', 'text-sm', 'text-gray-700');
    file_count_td.appendChild(document.createTextNode(feature_data.assignments.files.length));
    feature_row.appendChild(file_count_td);

    document.getElementById("features-table-body").appendChild(feature_row);

    abc_size_values.push(feature_data.metrics.abc_size);
    lines_of_code_values.push(feature_data.metrics.lines_of_code);
    cyclomatic_complexity_values.push(feature_data.metrics.cyclomatic_complexity);
  });

  let calculate_average = (list_of_values) => {
    let sum = list_of_values.reduce((accumulator, currentValue) => accumulator + currentValue, 0);
    let count = list_of_values.length;
    return Math.round((sum / count) * 100) / 100;
  }
  document.getElementById("abc-size-average").appendChild(document.createTextNode(calculate_average(abc_size_values)));
  document.getElementById("lines-of-code-average").appendChild(document.createTextNode(calculate_average(lines_of_code_values)));
  document.getElementById("complexity-average").appendChild(document.createTextNode(calculate_average(cyclomatic_complexity_values)));

  console.log(window.FEATURES);
});
