/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.github.sgoeschl.freemarker.cli;

import com.github.sgoeschl.freemarker.cli.impl.DocumentFactory;
import com.github.sgoeschl.freemarker.cli.impl.DocumentResolver;
import com.github.sgoeschl.freemarker.cli.impl.TemplateLoaderResolver;
import com.github.sgoeschl.freemarker.cli.model.Document;
import com.github.sgoeschl.freemarker.cli.model.Documents;
import com.github.sgoeschl.freemarker.cli.model.Settings;
import com.github.sgoeschl.freemarker.cli.tools.Tools;
import freemarker.cache.TemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.DefaultObjectWrapper;
import freemarker.template.DefaultObjectWrapperBuilder;
import freemarker.template.Template;
import freemarker.template.TemplateExceptionHandler;
import freemarker.template.Version;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;

import static freemarker.template.Configuration.VERSION_2_3_29;
import static java.nio.charset.StandardCharsets.UTF_8;
import static java.util.Objects.requireNonNull;

public class FreeMarkerTask implements Callable<Integer> {

    private static final String STDIN = "stdin";
    private static final Version FREEMARKER_VERSION = VERSION_2_3_29;

    private final Settings settings;
    private final Map<String, Object> tools;

    public FreeMarkerTask(Settings settings) {
        this.settings = requireNonNull(settings);
        this.tools = tools(settings);
    }

    @Override
    public Integer call() {
        return call(settings, tools);
    }

    private static Integer call(Settings settings, Map<String, Object> tools) {
        final DocumentResolver documentResolver = documentResolver(settings);
        try (Documents documents = documents(settings, documentResolver)) {
            final TemplateLoader templateLoader = templateLoader(settings);
            final Configuration configuration = configuration(settings, templateLoader);
            final Map<String, Object> dataModel = dataModel(settings, documents, tools);
            final Template template = getTemplate(settings, configuration);

            try (Writer out = settings.getWriter()) {
                template.process(dataModel, out);
            }

            return 0;
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("Failed to render FreeMarker Template: " + settings.getTemplateName(), e);
        }
    }

    private static Configuration configuration(Settings settings, TemplateLoader templateLoader) {
        final Configuration configuration = new Configuration(FREEMARKER_VERSION);
        configuration.setAPIBuiltinEnabled(false);
        configuration.setDefaultEncoding(settings.getTemplateEncoding().name());
        configuration.setLocale(settings.getLocale());
        configuration.setLogTemplateExceptions(false);
        configuration.setObjectWrapper(objectWrapper());
        configuration.setOutputEncoding(settings.getOutputEncoding().name());
        configuration.setTemplateLoader(templateLoader);
        configuration.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
        return configuration;
    }

    private static TemplateLoader templateLoader(Settings settings) {
        return new TemplateLoaderResolver(settings.getTemplateDirectories()).resolve();
    }

    private static DocumentResolver documentResolver(Settings settings) {
        return new DocumentResolver(settings.getSources(), settings.getInclude(), settings.getInputEncoding());
    }

    private static Documents documents(Settings settings, DocumentResolver documentResolver) {
        final List<Document> documents = new ArrayList<>(documentResolver.resolve());

        // Add optional document from STDIN at the start of the list since
        // this allows easy sequence slicing in FreeMarker.
        if (settings.isReadFromStdin()) {
            documents.add(0, DocumentFactory.create(STDIN, System.in, STDIN, UTF_8));
        }

        return new Documents(documents);
    }

    /**
     * Loading FreeMarker templates from absolute paths is not encouraged due to security
     * concern (see https://freemarker.apache.org/docs/pgui_config_templateloading.html#autoid_42)
     * which are mostly irrelevant when running on the command line. So we resolve the absolute file
     * instead of relying on existing template loaders.
     */
    private static Template getTemplate(Settings settings, Configuration configuration) throws IOException {
        final File templateFile = new File(settings.getTemplateName());
        if (isAbsoluteTemplateFile(templateFile)) {
            return new Template(settings.getTemplateName(),
                    FileUtils.readFileToString(templateFile, settings.getTemplateEncoding()),
                    configuration);
        } else {
            return configuration.getTemplate(settings.getTemplateName());
        }
    }

    private static Map<String, Object> dataModel(Settings settings, Documents documents, Map<String, Object> tools) {
        final Map<String, Object> dataModel = new HashMap<>();

        dataModel.put("Documents", documents);

        if (settings.isEnvironmentExposed()) {
            dataModel.putAll(System.getenv());
            dataModel.putAll(settings.getProperties());
        }

        dataModel.putAll(tools);

        return dataModel;
    }

    private static Map<String, Object> tools(Settings settings) {
        return new Tools().create(settings);
    }

    private static DefaultObjectWrapper objectWrapper() {
        final DefaultObjectWrapperBuilder builder = new DefaultObjectWrapperBuilder(FREEMARKER_VERSION);
        builder.setIterableSupport(false);
        return builder.build();
    }

    private static boolean isAbsoluteTemplateFile(File file) {
        return file.isAbsolute() && file.exists() & !file.isDirectory();
    }
}
