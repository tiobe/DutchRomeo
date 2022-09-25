for step_spec_to in spec.steps # Violation
    amcm_list_from_spec!(amcm_list, step_spec_from, step_spec_to; noise_center_location=noise_center_location, n_elt_per_ms_comb=n_elt_per_ms_comb)
end

function amcm_element(  # Violation
    value::Float64,
    c_from::AlignmentCoreModels.AbstractCoefficientContext,
    msid_from::Int,
    c_to::AlignmentCoreModels.AbstractCoefficientContext,
    msid_to::Int;
    noise_center_location::Float64=0.0
    )
    elt = ElementNode("elt")
    from = set_from_to_element(c_from; modelstepid=msid_from, from_to="From", noise_center_location=noise_center_location)
    to = set_from_to_element(c_to; modelstepid=msid_to, from_to="To", noise_center_location=noise_center_location)
    link!(elt, from)
    link!(elt, to)
    addelement!(elt, "Value", string(round(Decimal(value); digits=15)))
    return elt
end

function set_from_to_element(c::AlignmentCoreModels.AbstractCoefficientContext; modelstepid::Int=1, from_to::String="From", noise_center_location::Float64=0.0)  # Violation
    matrix_element = ElementNode(from_to)
    matrix_element.name = from_to
    addelement!(matrix_element, "ModelStepId", string(modelstepid))
    addelement!(matrix_element, "ModelSubStepId", string(c.substepId))
    basis = basis_from_to_element(c; noise_center_location=noise_center_location)
    link!(matrix_element, basis)
    addelement!(matrix_element, "Direction", set_direction(c))
    return matrix_element
end

function basis_from_to_element(c::AlignmentCoreModels.RadialBasisCoefficientContext; noise_center_location::Float64=0.0)  # Violation
    center_location = ElementNode("CenterLocation")
    noiseX = noise_center_location*(1-2*rand())
    noiseY = noise_center_location*(1-2*rand())
    addelement!(center_location, "Xposition", string(round(Decimal(c.center.x*1e3+noiseX); digits=6)))
    addelement!(center_location, "Yposition", string(round(Decimal(c.center.y*1e3+noiseY); digits=6)))
    return center_location
end

function basis_from_to_element(c::PolynomialCoefficientContext; noise_center_location::Float64=0.0)  # Violation
    term = ElementNode("Term")
    addelement!(term, "PowerX", string(c.powerX))
    addelement!(term, "PowerY", string(c.powerY))
    return term
end

function basis_from_to_element(c::AlignmentCoreModels.ParameterContext{AlignmentCoreModels.Tx}; noise_center_location::Float64=0.0)  # Violation
    p = PolynomialCoefficientContext(powerX=0, powerY=0, direction=XDirection(), substepId=c.substepId, gridType=c.gridType)
    return basis_from_to_element(p; noise_center_location=noise_center_location)
end

function basis_from_to_element(c::AlignmentCoreModels.ParameterContext{AlignmentCoreModels.Ty}; noise_center_location::Float64=0.0)  # Violation
    p = PolynomialCoefficientContext(powerX=0, powerY=0, direction=YDirection(), substepId=c.substepId, gridType=c.gridType)
    return basis_from_to_element(p; noise_center_location=noise_center_location)
end

function basis_from_to_element(c::AlignmentCoreModels.ParameterContext{AlignmentCoreModels.OffAxis}; noise_center_location::Float64=0.0)  # Violation
    p = PolynomialCoefficientContext(powerX=1, powerY=0, direction=XDirection(), substepId=c.substepId, gridType=c.gridType)
    return basis_from_to_element(p; noise_center_location=noise_center_location)
end

function basis_from_to_element(c::AlignmentCoreModels.ParameterContext{AlignmentCoreModels.OnAxis}; noise_center_location::Float64=0.0)  # Violation
    p = PolynomialCoefficientContext(powerX=1, powerY=0, direction=YDirection(), substepId=c.substepId, gridType=c.gridType)
    return basis_from_to_element(p; noise_center_location=noise_center_location)
end

set_direction(c::PolynomialCoefficientContext{D}) where D<:XDirection = "X"  # Violation
set_direction(c::PolynomialCoefficientContext{D}) where D<:YDirection = "Y"  # Violation
set_direction(c::AlignmentCoreModels.RadialBasisCoefficientContext{D}) where D<:XDirection = "X"  # Violation
set_direction(c::AlignmentCoreModels.RadialBasisCoefficientContext{D}) where D<:YDirection = "Y"  # Violation
set_direction(c::AlignmentCoreModels.ParameterContext{AlignmentCoreModels.Tx}) = "X"  # Violation
set_direction(c::AlignmentCoreModels.ParameterContext{AlignmentCoreModels.Ty}) = "Y"  # Violation
set_direction(c::AlignmentCoreModels.ParameterContext{AlignmentCoreModels.OffAxis}) = "X"  # Violation
set_direction(c::AlignmentCoreModels.ParameterContext{AlignmentCoreModels.OnAxis}) = "Y"  # Violation

function amcm_empty()  # Violation
    amcm = ElementNode("AlignmentModelCorrectionMatrix")
    addelement!(amcm, "Description", "Unknown")
    return amcm
end

function amcm_from_spec(spec::AlignmentStructures.AbstractModelSpecification; noise_center_location::Float64=0.0, n_elt_per_ms_comb::Int=0)  # Violation
    amcm = amcm_empty()
    amcm_list = amcm_list_from_spec(spec; noise_center_location=noise_center_location, n_elt_per_ms_comb=n_elt_per_ms_comb)
    link!(amcm, amcm_list)
    return amcm
end

function amcm_list_from_spec(spec::ModelSpecification; noise_center_location::Float64=0.0, n_elt_per_ms_comb::Int=0)  # Violation
    amcm_list = ElementNode("AlignmentModelCorrectionList")
    for step_spec_from in spec.steps
        for step_spec_to in spec.steps
            amcm_list_from_spec!(amcm_list, step_spec_from, step_spec_to; noise_center_location=noise_center_location, n_elt_per_ms_comb=n_elt_per_ms_comb)
        end
    end
    return amcm_list
end

function amcm_list_from_spec(spec::ModelStepSpecification; noise_center_location::Float64=0.0, n_elt_per_ms_comb::Int=0)  # Violation
    amcm_list = ElementNode("AlignmentModelCorrectionList")
    amcm_list_from_spec!(amcm_list, spec, spec; noise_center_location=noise_center_location, n_elt_per_ms_comb=n_elt_per_ms_comb)
    return amcm_list
end

function amcm_list_from_spec!(amcm_list::EzXML.Node, spec_from::ModelStepSpecification, spec_to::ModelStepSpecification; noise_center_location::Float64=0.0, n_elt_per_ms_comb::Int=0)  # Violation
    if(n_elt_per_ms_comb == 0)
        for c_from in AlignmentCoreModels.coefficient_context(spec_from)
            modelstepid_from = spec_from.stepId
            for c_to in AlignmentCoreModels.coefficient_context(spec_to)
                modelstepid_to = spec_to.stepId
                elt = amcm_element(round(rand();digits=15), c_from, modelstepid_from, c_to, modelstepid_to; noise_center_location=noise_center_location)
                link!(amcm_list, elt)
            end
        end
    else
        for i in 1:n_elt_per_ms_comb
            c_from = rand(AlignmentCoreModels.coefficient_context(spec_from))
            modelstepid_from = spec_from.stepId
            c_to = rand(AlignmentCoreModels.coefficient_context(spec_to))
            modelstepid_to = spec_to.stepId
            elt = amcm_element(round(rand();digits=15), c_from, modelstepid_from, c_to, modelstepid_to; noise_center_location=noise_center_location)
            link!(amcm_list, elt)
        end
    end
    return nothing
end

for step_spec_to in spec.steps
    amcm_list_from_spec!(amcm_list, step_spec_from, step_spec_to; noise_center_location=noise_center_location, n_elt_per_ms_comb=n_elt_per_ms_comb)
end
