package com.tiobe.julia;

import com.tiobe.antlr.JuliaParser;
import org.antlr.v4.runtime.BufferedTokenStream;

import java.util.List;

public class Rule1 extends Rule {
    public Rule1(final List<Violation> violations) {
        super(violations);
    }

    @Override
    public String getSynopsis() {
        return "Cyclomatic complexity of a function";
    }

    @Override
    public void check(final JuliaParser.FunctionDefinition1Context ctx, final BufferedTokenStream tokens) {
        final long cyclox = 5;
        addViolation(1, ctx, String.format("The cyclomatic complexity for the function is %d", cyclox));
    }
}
