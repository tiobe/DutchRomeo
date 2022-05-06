package com.tiobe.julia;

import com.tiobe.antlr.JuliaParser;
import org.antlr.v4.runtime.BufferedTokenStream;
import org.antlr.v4.runtime.ParserRuleContext;

import java.nio.file.Path;
import java.util.List;

public abstract class Rule {
    private final transient List<Violation> violations;
    private String id = this.getClass().getSimpleName();

    public Rule(final List<Violation> violations) {
        this.violations = violations;
    }

    public String getRuleId() {
        return id;
    }

    public abstract String getSynopsis();

    protected void addViolation(final Path filename, final ParserRuleContext ctx, final String extraMessage) {
        addViolation(new Violation(this, filename, ctx, extraMessage));
    }
    protected void addViolation(final Violation violation) {
        violations.add(violation);
    }

    public void check(final Path filename, final BufferedTokenStream tokens) {
    }

    public void check(final Path filename, final JuliaParser.MainContext ctx, final BufferedTokenStream tokens) {
    }

    public void check(final Path filename, final JuliaParser.FunctionDefinition1Context ctx, final BufferedTokenStream tokens) {
    }
}
