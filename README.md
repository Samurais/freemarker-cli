# 1. Introduction

For a customer I needed a little bit of test data management - to make a long story short (after writing a few scripts) it boiled down to transforming one or more JSON files to something human readable.

What are the options

* The cool kids say 'Node.js' - but they always say 'Node.js' 
* Some fancy Groovy scripts using markup builder - but the Groovy syntax looks a bit odd
* Using 'JsonPath' and 'Velocity' to reuse good & old stuff

So I went with 'Apache Groovy', 'JsonPath' and 'Apache Velocity'

* Playing with Groovy over the public holidays
* Groovy has a built-in package manager which makes distribution a breeze
* Provding samples to transform JSON to Markdown

Using Velocity actually created some minor issues so I migrated to FreeMarker

# 2. Design Goals

* Support multiple documents for a single transformation
* Support transformation of CSV files using [Apache Commons CSV](http://commons.apache.org/proper/commons-csv/)
* Support for reading document content from STDIN to integrate with command line tools
* Add some commonly useful information such as `System Properties`, `Enviroment Variables`

# 3. Usage

```
freemarker-commandLine> groovy freemarker-commandLine.groovy 
usage: groovy freemarker-commandLine.groovy [options] file[s]
 -h,--help             Usage information
 -l,--locale <arg>     Locale value
 -o,--output <arg>     Output file
 -t,--template <arg>   Template name
 -v,--verbose          Verbose mode
```

# 4. Examples

## 4.1 Transforming GitHub JSON To Markdown

A simple example with real JSON data

### Invocation

You can either use the existing JSON sample

> groovy freemarker-commandLine.groovy -t temlates/json/md/github-users.ftl site/sample/json/github-users.json 

or pipe a cURL response

> curl -s https://api.github.com/users | groovy freemarker-commandLine.groovy -t templates/json/md/github-users.ftl

### FreeMarker Template

```
<#ftl output_format="plainText" >
<#assign json = JsonPath.parse(documents[0].content)>
<#assign users = json.read("$[*]")>
<#--------------------------------------------------------------------------->
# GitHub Users

Report generated at ${.now?iso_utc}

<#list users as user>
<#assign userAvatarUrl = user.avatar_url>
<#assign userHomeUrl = user.html_url>
# ${user.login}

| User                                                    | Homepage                                      |
|:--------------------------------------------------------|:----------------------------------------------|
| <img src="${user.avatar_url}" width="48" height="48" /> | [${userHomeUrl}](${userHomeUrl})              |
</#list>
```

creates the following output

![Github Users](./site/image/github.png "Github Users")


## 4.2 Markdown Test User Documentation

For a customer I created a Groovy script to fetch all products for a list of users - the script generates a JSON file which can be easily transformed to Markdown

```
> groovy freemarker-commandLine.groovy -t templates/json/md/customer-user-products.ftl  site/sample/json/customer-user-products.json
```

The resulting file can be viewed with any decent Markdown viewer

![Customer User Products](./site/image/customer-user-products.png "Customer User Products")

## 4.3 CSV to Markdown Transformation

Sometimes you have a CSV file which needs to be translated in Markdown or HTML - there are on-line solutions available such as [CSV To Markdown Table Generator](https://donatstudios.com/CsvToMarkdownTable) but having a local solution gives you more flexibility.

```
> groovy freemarker-commandLine.groovy -t templates/csv/md/transform.ftl site/sample/csv/contract.csv 
> groovy freemarker-commandLine.groovy -t templates/csv/html/transform.ftl site/sample/csv/contract.csv 
```

The FreeMarker template is shown below

```
<#ftl output_format="HTML" >
<#assign name = documents[0].name>
<#assign content = documents[0].content>
<#assign cvsFormat = CSVFormat.DEFAULT.withHeader()>
<#assign csvParser = CSVParser.parse(content, cvsFormat)>
<#assign csvHeaders = csvParser.getHeaderMap()?keys>
<#assign csvRecords = csvParser.records>
<#--------------------------------------------------------------------------->
<!DOCTYPE html>
<html>
<head>
    <title>${name}</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
</head>
<body>
<table class="table table-striped">
    <@writeHeaders headers=csvHeaders/>
    <@writeColums columns=csvRecords/>
</table>
</body>
</html>
<#--------------------------------------------------------------------------->
<#macro writeHeaders headers>
    <tr>
    <#list headers as header>
        <th>${header}</th>
    </#list>
    </tr>
</#macro>
<#--------------------------------------------------------------------------->
<#macro writeColums columns>
    <#list columns as column>
    <tr>
    <#list column.iterator() as field>
        <td>${field}</td>
    </#list>
    </tr>
    </#list>
</#macro>

```

The resulting file actually looks pleasant when compared to raw CSV

![Contract CSV to HTML](./site/image/contract.png "Contract CSV to HTML")

## 4.4 Transform XML To Plain Text

Of course you can also transform a XML document

```
> groovy freemarker-commandLine.groovy -t ./templates/xml/txt/recipients.ftl site/sample/xml/recipients.xml 
```

using the following template

```
<#ftl output_format="plainText" >
<#assign xml = XmlParser.parse(documents[0].content)>
<#list xml.recipients.person as recipient>
To: ${recipient.name}
${recipient.address}

Dear ${recipient.name},

Thank you for your interest in our products. We will be sending you a catalog shortly.
To take advantage of our free gift offer, please fill in the survey attached to this
letter and return it to the address on the reverse. Only one participant is allowed for
each household.

Sincere salutations,


D. H.

---------------------------------------------------------------------------------------
</#list>

```

which generates the following output

```text
To: John Smith
3033 Long Drive, Houston, TX

Dear John Smith,

Thank you for your interest in our products. We will be sending you a catalog shortly.
To take advantage of our free gift offer, please fill in the survey attached to this
letter and return it to the address on the reverse. Only one participant is allowed for
each household.

Sincere salutations,


D. H.
```








