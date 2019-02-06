#!/bin/sh

# Check that groovy is on the path

hash groovy 2>/dev/null || { echo >&2 "I require Apache Groovy but it's not installed.  Aborting."; exit 1; }

# Run all the samples being documented 

mkdir target 2>/dev/null
mkdir target/out 2>/dev/null

echo "templates/demo.ftl"
groovy freemarker-cli.groovy -t templates/demo.ftl README.md > target/out/demo.txt || { echo >&2 "Test failed.  Aborting."; exit 1; }

#############################################################################
# CSV
#############################################################################

echo "templates/csv/html/transform.ftl"
groovy freemarker-cli.groovy -t templates/csv/html/transform.ftl site/sample/csv/contract.csv > target/out/contract.html || { echo >&2 "Test failed.  Aborting."; exit 1; }

echo "templates/csv/md/transform.ftl"
groovy freemarker-cli.groovy -t templates/csv/md/transform.ftl site/sample/csv/contract.csv > target/out/contract.md || { echo >&2 "Test failed.  Aborting."; exit 1; }

#############################################################################
# CSV To XML-FO & PDF
#############################################################################

echo "templates/csv/fo/transform.ftl"
groovy freemarker-cli.groovy -t templates/csv/fo/transform.ftl site/sample/csv/locker-test-users.csv > target/out/locker-test-users.fo || { echo >&2 "Test failed.  Aborting."; exit 1; }

if hash fop 2>/dev/null; then
	echo "fop -fo target/out/locker-test-users.fo target/out/locker-test-users.pdf"
    fop -fo target/out/locker-test-users.fo target/out/locker-test-users.pdf 2>/dev/null || { echo >&2 "Test failed.  Aborting."; exit 1; }
fi

echo "templates/csv/fo/transactions.ftl"
groovy freemarker-cli.groovy -t templates/csv/fo/transactions.ftl site/sample/csv/transactions.csv > target/out/transactions.fo || { echo >&2 "Test failed.  Aborting."; exit 1; }

if hash fop 2>/dev/null; then
	echo "fop -fo target/out/transactions.fo target/out/transactions.pdf"
    fop -fo target/out/transactions.fo target/out/transactions.pdf 2>/dev/null || { echo >&2 "Test failed.  Aborting."; exit 1; }
fi

#############################################################################
# Excel
#############################################################################

echo "templates/excel/html/transform.ftl"
groovy freemarker-cli.groovy -t templates/excel/html/transform.ftl site/sample/excel/test.xls > target/out/test.xls.html || { echo >&2 "Test failed.  Aborting."; exit 1; }
groovy freemarker-cli.groovy -t templates/excel/html/transform.ftl site/sample/excel/test.xlsx > target/out/test.xslx.html || { echo >&2 "Test failed.  Aborting."; exit 1; }
groovy freemarker-cli.groovy -t templates/excel/html/transform.ftl site/sample/excel/test-multiple-sheets.xlsx > target/out/test-multiple-sheets.xlsx.html || { echo >&2 "Test failed.  Aborting."; exit 1; }

echo "templates/excel/md/transform.ftl"
groovy freemarker-cli.groovy -t templates/excel/md/transform.ftl site/sample/excel/test-multiple-sheets.xlsx > target/out/test-multiple-sheets.xlsx.md || { echo >&2 "Test failed.  Aborting."; exit 1; }

#############################################################################
# HTML
#############################################################################

echo "templates/html/csv/dependencies.ftl"
 groovy freemarker-cli.groovy -t templates/html/csv/dependencies.ftl site/sample/html/dependencies.html > target/out/dependencies.csv || { echo >&2 "Test failed.  Aborting."; exit 1; }

#############################################################################
# JSON
#############################################################################

echo "templates/json/csv/swagger-endpoints.ftl"
groovy freemarker-cli.groovy -t templates/json/csv/swagger-endpoints.ftl site/sample/json/swagger-spec.json > target/out/swagger-spec.csv || { echo >&2 "Test failed.  Aborting."; exit 1; }

echo "templates/json/html/customer-user-products.ftl"
groovy freemarker-cli.groovy -t templates/json/html/customer-user-products.ftl site/sample/json/customer-user-products.json > target/out/customer-user-products.html || { echo >&2 "Test failed.  Aborting."; exit 1; }

if hash wkhtmltopdf 2>/dev/null; then
	echo "wkhtmltopdf -O landscape target/out/customer-user-products.html target/out/customer-user-products.pdf"
    wkhtmltopdf -O landscape target/out/customer-user-products.html target/out/customer-user-products.pdf 2>/dev/null || { echo >&2 "Test failed.  Aborting."; exit 1; }
fi

echo "templates/json/md/customer-user-products.ftl"
groovy freemarker-cli.groovy -t templates/json/md/customer-user-products.ftl  site/sample/json/customer-user-products.json > target/out/customer-user-products.md || { echo >&2 "Test failed.  Aborting."; exit 1; }

if hash curl 2>/dev/null; then
echo "templates/json/md/github-users.ftl"
groovy freemarker-cli.groovy -t templates/json/md/github-users.ftl site/sample/json/github-users.json > target/out/github-users-curl.md || { echo >&2 "Test failed.  Aborting."; exit 1; }
fi

#############################################################################
# Properties
#############################################################################

echo "templates/properties/csv/locker-test-users.ftl"
groovy freemarker-cli.groovy -i **/*.properties -t templates/properties/csv/locker-test-users.ftl site/sample/properties > target/out/locker-test-users.csv || { echo >&2 "Test failed.  Aborting."; exit 1; }

#############################################################################
# XML
#############################################################################

echo "templates/xml/txt/recipients.ftl"
groovy freemarker-cli.groovy -t ./templates/xml/txt/recipients.ftl site/sample/xml/recipients.xml > target/out/recipients.txt || { echo >&2 "Test failed.  Aborting."; exit 1; }

echo "Created the following sample files in ./target/out"
ls -l ./target/out