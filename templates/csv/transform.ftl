<#ftl output_format="plainText" strip_text="true">
<#--
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
-->
<#-- Parse incoming CSV with user-supplied configuration -->
<#assign delimiter = SystemProperties["csv.delimiter"]!"\t">
<#assign format = SystemProperties["csv.format"]!"DEFAULT">
<#assign cvsFormat = CSVFormat[format].withDelimiter(delimiter)>
<#assign csvParser = CSVTool.parse(documents[0], cvsFormat)>
<#-- Setup CSVPrinter for transformed CSV -->
<#assign csvPrinter = CSVTool.printer(CSVFormat.DEFAULT)>
<#-- Print each line without materializing the CSV in memory -->
<#compress>
    <#list csvParser.iterator() as record>
        ${csvPrinter.printRecord(record)}
    </#list>
</#compress>
