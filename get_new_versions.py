import pandas as pd
import re
from urllib.request import urlopen
from collections import namedtuple
import re
import requests
import looseversion
import numpy as np
import time
import pandas as pd
from selenium import webdriver
from selenium.webdriver import Chrome
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
import datetime

MatchResult = namedtuple("MatchResult", ["version"])

def scrape_using_selenium(url,pattern):
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.page_load_strategy = "none"
    driver = Chrome(options=options)
    driver.implicitly_wait(5)
    driver.get(url)
    time.sleep(10)  # Wait for the page to load.
    select_element = driver.find_element(By.NAME, "fcselectFixesresults_length")
    # Create a Select object
    select = Select(select_element)
    # Method 1: Select by visible text
    select.select_by_visible_text("All")
    # Optionally, you can get the selected option to verify
    selected_option = select.first_selected_option
    print("Selected option:", selected_option.text)
    found_matches = []
    elements = driver.find_elements(By.CLASS_NAME, "fc-all")
    text = " ".join([element.text for element in elements])
    re_pattern_compiled = re.compile(pattern)
    match_array = re_pattern_compiled.findall(text)
    match_array = list(set(match_array))
    return match_array

def convert_str_to_float(version_string):
    # Check if the input is already a string
    if isinstance(version_string, str):
        print("entering the conversion")
        # Split the version string into segments
        segments = version_string.split('.')
        
        # Convert each segment to an integer and combine them
        version_float = '.'.join(map(str, map(int, segments)))
        
        return version_float
    else:
        # Return the input unchanged if it's not a string
        return version_string

def get_maximum_version(version_array, version_major_minor_match=""):
    """
    Gets the maximum version string from an array.

    Args:
        version_array (list): Array of version strings.
        version_major_minor_match (str, optional): Major Minor version to filter matches.
            Defaults to an empty string.

    Returns:
        str: The maximum version from the array.
    """
    filtered_array = []

    # Filter the version array based on version_major_minor_match if provided
    if version_major_minor_match:
        if not version_major_minor_match.endswith("."):
            version_major_minor_match += "."
        filtered_array = [item for item in version_array if item.startswith(version_major_minor_match)]
        version_array = filtered_array

    # Get the maximum version
    if version_array:
        version_maximum = max(version_array, key=looseversion.LooseVersion)
    else:
        version_maximum = None

    return version_maximum


def url_text_searcher_array(url, re_pattern):
    """
    Downloads a URL using requests and performs a regular expression match
    on the text. Returns an array of matches instead of the first match.
    """

    result_output_var_name = "match"  # default output variable name
    full_results = False  # default behavior to return unique matches only

    # Compile the regular expression pattern
    re_pattern_compiled = re.compile(re_pattern)

    # Fetch content from the URL
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raise an exception for bad status codes
        content = response.text
    except requests.exceptions.RequestException as e:
        raise ValueError(f"Error fetching content from URL: {str(e)}")

    # Search for the regular expression pattern in the content
    match_array = re_pattern_compiled.findall(content)

    if not match_array:
        raise ValueError(f"No match found on URL: {url}")

    # Optionally return all results if full_results is True
    if not full_results:
        match_array = list(set(match_array))

    return match_array

def extract_version_from_url(url, re_pattern):
    class URLTextSearcher:
        def __init__(self, url, re_pattern):
            self.url = url
            self.re_pattern = re_pattern

        def fetch_content(self):
            try:
                with urlopen(self.url) as response:
                    content = response.read().decode("utf-8")
                return content
            except Exception as e:
                print(f"Error fetching content from {self.url}: {e}")
                return None

        def search_version(self, content):
            re_pattern = re.compile(self.re_pattern)
            match = re_pattern.search(content)
            if match:
                version = match.group(1)  # Assuming the version is captured in the first group
                return MatchResult(version)
            else:
                print("No match found.")
                return None

    searcher = URLTextSearcher(url, re_pattern)
    content = searcher.fetch_content()
    if content:
        result = searcher.search_version(content)
        if result:
            # print(f"Version found: {result.version}")
            # Split the version string into segments
            #version_string = convert_str_to_float(result.version)
            version_string = str(result.version)

            return version_string
    else:
        print("Failed to fetch content.")

def get_date_time():
    current_datetime = datetime.datetime.now()
    formatted_datetime = current_datetime.strftime("%Y-%m-%d %H:%M")
    return formatted_datetime

def csv_to_list(csv_file_path):
    try:
        # Read the Excel file into a pandas DataFrame
        df = pd.read_csv(csv_file_path)

        # Convert each row of the DataFrame to a list
        rows_as_lists = df.values.tolist()

        return rows_as_lists

    except Exception as e:
        print("An error occurred:", str(e))

csv_file_path = "software_data.csv"  # Change this to the path of your Excel file
new_versions = []

rows_as_lists = csv_to_list(csv_file_path)
if rows_as_lists:
    print("Rows as lists:")
    for row in rows_as_lists:
        current_version = str(row[4])
        print("--------------------------------------------------")
        if row[3] == "Yes":
            # checking if IBM exists in the first cell and if it does loop here
            if "IBM" in row[0]:
                matches = scrape_using_selenium(row[1], row[2])
                maximum_version = get_maximum_version(matches)
                if float(maximum_version)>float(current_version):
                    result = f"{row[0]} - current version: {current_version} - version found: {maximum_version} - (new update available)"
                    row[5] = maximum_version
                    row[6] = "New update available"
                    row[7] = get_date_time()
                    new_versions.append(row[0]+" "+maximum_version)
                else:   
                    result = f"{row[0]} - current version: {current_version} - version found: {maximum_version}"
                    row[5] = "Same"
                    row[6] = "Same version"
                    row[7] = get_date_time()
            else:
                matches = url_text_searcher_array(row[1],row[2])
                maximum_version = get_maximum_version(matches)
                # hardcoding the usecase for mariadb since it is unique and an edge case
                if "MariaDB" in row[0]:
                    matches = url_text_searcher_array(row[1]+maximum_version,'release_id\": \"(?P<mmi_version>\d+\.\d+\.\d+)')
                    maximum_version = get_maximum_version(matches)
                if str(maximum_version)!=current_version:
                    result = f"{row[0]} - current version: {current_version} - version found: {maximum_version} - (new update available)"
                    row[5] = maximum_version
                    row[6] = "New update available"
                    row[7] = get_date_time()
                    new_versions.append(row[0]+" "+maximum_version)
                else:   
                    result = f"{row[0]} - current version: {current_version} - version found: {maximum_version}"
                    row[5] = "Same"
                    row[6] = "Same version"
                    row[7] = get_date_time()
            print(result)
        else:
            extracted_version = extract_version_from_url(row[1],row[2])
            if str(extracted_version)!=current_version:
                result = f"{row[0]} - current version: {current_version} - version found: {extracted_version} - (new update available)"
                row[5] = extracted_version
                row[6] = "New update available"
                row[7] = get_date_time()
                new_versions.append(row[0]+" "+extracted_version)
                print(result)
            else:
                print(f"{row[0]} - current version: {current_version} - version found: {extracted_version}")
                row[5] = "Same"
                row[6] = "Same version"
                row[7] = get_date_time()
    print("--------------------------------------------------")
for row in rows_as_lists:
    print(row)
if new_versions is not None:
    print(new_versions)

df = pd.read_csv(csv_file_path)
headers = df.columns.tolist()
df = pd.DataFrame(rows_as_lists, columns=headers)
print(df)
# deleting colums with index 1,2,3 
df = df.drop(df.columns[[1, 2, 3]], axis=1)
# svaing the df to a csv file
df.to_csv('output.csv', index=False)